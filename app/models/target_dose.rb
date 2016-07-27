class TargetDose
  include ActiveModel::Model

  attr_accessor :patient, :antigen_series_dose

  def initialize(patient:, antigen_series_dose:)
    @patient             = patient
    @antigen_series_dose = antigen_series_dose
  end

  [
    'dose_number', 'absolute_min_age', 'min_age', 'earliest_recommended_age',
    'latest_recommended_age', 'max_age', 'allowable_interval_type',
    'allowable_interval_absolute_min', 'required_gender', 'recurring_dose'
  ].each do |action|
    define_method(action) do
      return nil if @antigen_series_dose.nil?
      @antigen_series_dose.send(action)
    end
  end




end
