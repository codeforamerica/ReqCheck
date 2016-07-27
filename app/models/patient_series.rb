class PatientSeries
  include ActiveModel::Model

  attr_reader :target_doses, :patient, :antigen_series

  def initialize(patient:, antigen_series:)
    @patient        = patient
    @antigen_series = antigen_series
    @target_doses   = []
  end

  def create_target_doses
    @target_doses = @antigen_series.doses.map do |antigen_series_dose|
      TargetDose.new(antigen_series_dose: antigen_series_dose, patient: @patient)
    end
    @target_doses
  end
end
