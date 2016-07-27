class PatientSeries
  include ActiveModel::Model

  attr_accessor :patient, :antigen_series

  def initialize(patient:, antigen_series:)
    @patient        = patient
    @antigen_series = antigen_series
  end
end
