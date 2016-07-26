class TargetDose
  include ActiveModel::Model

  attr_accessor :patient, :antigen_series_dose

  def initialize(patient:, antigen_series_dose:)
    @patient             = patient
    @antigen_series_dose = antigen_series_dose
  end



end
