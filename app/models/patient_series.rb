class PatientSeries
  include ActiveModel::Model
  include CheckType

  attr_reader :target_doses, :patient, :antigen_series

  def initialize(patient:, antigen_series:)
    CheckType.enforce_type(patient, Patient)
    CheckType.enforce_type(antigen_series, AntigenSeries)
    @patient        = patient
    @antigen_series = antigen_series
    @target_doses   = []
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

  def self.create_antigen_patient_serieses(antigen:, patient:)
    antigen.series.map do |antigen_series|
      self.new(antigen_series: antigen_series, patient: patient)
    end
  end

end
