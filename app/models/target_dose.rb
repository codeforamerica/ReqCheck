class TargetDose
  include ActiveModel::Model
  include AgeCalc
  include TargetDoseEvaluation
  include FutureDoseEvaluation

  attr_reader :satisfied, :status_hash, :antigen_administered_record,
              :earliest_dose_date, :evaluator, :evaluation

  def initialize(patient_series:, antigen_series_dose:)
    @antigen_series_dose = antigen_series_dose
    @patient_series      = patient_series
    @evaluator           = TargetDoseEvaluator.new(self)
  end

  [
    'dose_number', 'absolute_min_age', 'min_age', 'earliest_recommended_age',
    'latest_recommended_age', 'max_age', 'intervals', 'required_gender',
    'recurring_dose', 'dose_vaccines', 'preferable_vaccines',
    'allowable_vaccines, conditional_skip'
  ].each do |action|
    define_method(action) do
      return nil if antigen_series_dose.nil?
      antigen_series_dose.send(action)
    end
  end

  def patient
    patient_series.patient
  end

  def add_evaluator(evaluator)
    @evaluator = evaluator
  end

  def evaluate_antigen_administered_record(
    antigen_administered_record
  )
    if evaluation.valid
      raise Error('The TargetDose is already Valid!')
    end
    @evaluation = evaluate_satisfy_target_dose(
      antigen_administered_record
    )
    @evaluation.satisfied?
  end

  def has_conditional_skip?
    !self.antigen_series_dose.conditional_skip.nil?
  end

  def eligible?
    return false if self.recurring_dose == true
    min_age      = self.min_age
    max_age      = self.max_age
    patient_dob  = @patient.dob
    todays_date  = DateTime.now
                    .in_time_zone('Central Time (US & Canada)').to_date

    unless min_age.nil?
      min_age_date = create_calculated_date(min_age, patient_dob)
      unless validate_date_equal_or_after(min_age_date, todays_date)
        return false
      end
    end
    unless max_age.nil?
      max_age_date = create_calculated_date(max_age, patient_dob)
      unless validate_date_equal_or_before(max_age_date, todays_date)
        return false
      end
    end
    true
  end

  def date_administered
    return nil if antigen_administered_record.nil?
    antigen_administered_record.date_administered
  end

  def first_dose?
    dose_number == 1
  end

  def evaluate_preferable_vaccine(antigen_administered_record)
    preferable_vaccine_status_hash = {}
    preferable_cvx = self.preferable_vaccines.map(&:cvx_code)
    if !preferable_cvx.include?(antigen_administered_record.cvx_code)
      preferable_vaccine_status_hash[:preferable] = 'No'
      preferable_vaccine_status_hash[:reason] = 'not_included'
    end
  end

  def evaluate_satisfy_target_dose(antigen_administered_record)
    previous_status_hash        = nil
    date_of_previous_dose       = nil
    unless previous_satisfied_target_doses.length == 0
      previous_target_dose = previous_satisfied_target_doses[-1]
      previous_status_hash =
        previous_target_dose.status_hash
      date_of_previous_dose =
        previous_target_dose.antigen_administered_record.date_administered
    end
    evaluate_target_dose_satisfied(
      conditional_skip: @antigen_series_dose.conditional_skip,
      antigen_series_dose: @antigen_series_dose,
      preferable_intervals: @antigen_series_dose.preferable_intervals,
      allowable_intervals: @antigen_series_dose.allowable_intervals,
      antigen_series_dose_vaccines: @antigen_series_dose.dose_vaccines,
      patient_dob: @patient.dob,
      patient_gender: @patient.gender,
      patient_vaccine_doses: @patient.vaccine_doses,
      dose_cvx: antigen_administered_record.cvx_code,
      date_of_dose: antigen_administered_record.date_administered,
      dose_trade_name: antigen_administered_record.trade_name,
      dose_volume: antigen_administered_record.dosage,
      date_of_previous_dose: date_of_previous_dose,
      previous_dose_status_hash: previous_status_hash,
      previous_satisfied_target_doses: previous_satisfied_target_doses
    )
  end

  def get_earliest_future_target_dose_date(satisfied_target_doses)
    future_dose_dates = create_future_dose_dates(
      patient,
      self,
      vaccine_doses: patient.vaccine_doses,
      satisfied_target_doses: satisfied_target_doses
    )
    @earliest_dose_date = find_maximium_min_date(future_dose_dates)
    @earliest_dose_date
  end

  def self.create_target_doses(patient_series)
    target_doses = patient_series.doses.map do |antigen_series_dose|
      TargetDose.new(antigen_series_dose: antigen_series_dose,
                     patient_series: patient_series)
    end
    target_doses.sort_by!(&:dose_number)
    patient_series.add_target_doses(target_doses)
    target_doses
  end
end

