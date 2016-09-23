class TargetDose
  include ActiveModel::Model
  include AgeCalc
  include TargetDoseEvaluation

  attr_accessor :patient, :antigen_series_dose
  attr_reader :satisfied, :status_hash, :antigen_administered_record

  def initialize(patient:, antigen_series_dose:)
    @antigen_series_dose         = antigen_series_dose
    @patient                     = patient
    @status_hash                 = nil
    @antigen_administered_record = nil
  end

  [
    'dose_number', 'absolute_min_age', 'min_age', 'earliest_recommended_age',
    'latest_recommended_age', 'max_age', 'intervals', 'required_gender',
    'recurring_dose', 'dose_vaccines', 'preferable_vaccines',
    'allowable_vaccines'
  ].each do |action|
    define_method(action) do
      return nil if antigen_series_dose.nil?
      antigen_series_dose.send(action)
    end
  end

  def evaluate_antigen_administered_record(
    antigen_administered_record,
    previous_satisfied_target_doses=[]
  )
    if !@status_hash.nil? && @status_hash[:evaluation_status] == 'valid'
      raise Error('The TargetDose is already Valid!')
    end
    @antigen_administered_record = antigen_administered_record
    @status_hash = evaluate_satisfy_target_dose(
      antigen_administered_record,
      previous_satisfied_target_doses
    )
    @satisfied   =
      ['satisfied', 'skipped'].include?(@status_hash[:target_dose_status])
    @satisfied
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
      min_age_date = create_patient_age_date(min_age, patient_dob)
      unless validate_date_equal_or_after(min_age_date, todays_date)
        return false
      end
    end
    unless max_age.nil?
      max_age_date = create_patient_age_date(max_age, patient_dob)
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

  def evaluate_satisfy_target_dose(antigen_administered_record,
                                   previous_satisfied_target_doses=[])
    previous_status_hash        = nil
    date_of_previous_dose       = nil
    satisfied_target_dose_dates = []
    unless previous_satisfied_target_doses.length == 0
      satisfied_target_dose_dates =
        previous_satisfied_target_doses.map do |satisfied_target_dose|
          satisfied_target_dose.antigen_administered_record.date_administered
        end
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
      previous_satisfied_target_dose_dates: satisfied_target_dose_dates
    )
  end
end

