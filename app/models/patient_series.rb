class PatientSeries
  include ActiveModel::Model
  include CheckType
  include TimeCalc

  attr_reader :target_doses, :patient, :antigen_series,
              :eligible_target_doses, :non_eligible_target_doses

  def initialize(patient:, antigen_series:)
    CheckType.enforce_type(patient, Patient)
    CheckType.enforce_type(antigen_series, AntigenSeries)
    @patient                   = patient
    @antigen_series            = antigen_series
    @target_doses              = []
    @eligible_target_doses     = []
    @non_eligible_target_doses = []
    create_target_doses
  end

  [
    'name', 'target_disease', 'vaccine_group',
    'default_series', 'preference_number',
    'product_path', 'min_start_age', 'max_start_age'
  ].each do |action|
    define_method(action) do
      return nil if @antigen_series.nil?
      @antigen_series.send(action)
    end
  end

  def create_target_doses
    @target_doses = @antigen_series.doses.map do |antigen_series_dose|
      TargetDose.new(antigen_series_dose: antigen_series_dose, patient: @patient)
    end
    @target_doses.sort_by!(&:dose_number)
  end

  def check_max_age(max_age_string, dob)
    !date_diff_vs_string_time_diff(past_date: dob, time_diff_string: max_age_string)
  end

  def check_min_age(min_age_string, dob)
    date_diff_vs_string_time_diff(past_date: dob, time_diff_string: min_age_string)
  end

  def evaluate_target_dose(target_dose, patient)
    return false if !check_min_age(target_dose.absolute_min_age, patient.dob)
    return false if !check_max_age(target_dose.max_age, patient.dob)
    true
  end

  def pull_eligible_target_doses
    @eligible_target_doses, @non_eligible_target_doses = [], []
    @target_doses.each do |target_dose|
      if evaluate_target_dose(target_dose, @patient)
        @eligible_target_doses << target_dose
      else
        @non_eligible_target_doses << target_dose
      end
    end
    @eligible_target_doses
  end

  def self.create_antigen_patient_serieses(antigen:, patient:)
    patient_series = antigen.series.map do |antigen_series|
      self.new(antigen_series: antigen_series, patient: patient)
    end
    patient_series.sort_by(&:preference_number)
  end

end
