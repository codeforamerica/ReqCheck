class TargetDose
  include ActiveModel::Model
  include AgeCalc

  attr_accessor :patient, :antigen_series_dose
  attr_reader :eligible

  def initialize(patient:, antigen_series_dose:)
    @patient               = patient
    @antigen_series_dose   = antigen_series_dose
    set_target_dose_age_attributes(antigen_series_dose, patient.dob)
    @eligible              = nil
  end

  [
    'dose_number', 'absolute_min_age', 'min_age', 'earliest_recommended_age',
    'latest_recommended_age', 'max_age', 'allowable_interval_type', 'intervals',
    'allowable_interval_absolute_min', 'required_gender', 'recurring_dose'
  ].each do |action|
    define_method(action) do
      return nil if antigen_series_dose.nil?
      antigen_series_dose.send(action)
    end
  end

  def set_target_dose_age_attributes(antigen_series_dose, dob)
    [
      'absolute_min_age', 'min_age', 'earliest_recommended_age',
      'latest_recommended_age', 'max_age'
    ].each do |action|
      date_action  = action + '_date'
      age_string   = antigen_series_dose.read_attribute(action)
      patient_date = create_patient_age_date(age_string, dob)
      instance_variable_set("@#{date_action}", patient_date)
    end
  end

  # def age_eligible?(dob)
  #   @eligible = true
  #   @eligible = check_min_age(self.absolute_min_age, dob)
  #   if @eligible
  #     if self.max_age
  #       @eligible = check_max_age(self.max_age, dob)
  #     end
  #   end
  #   @eligible
  # end

  def evaluate_antigen_administered_record(antigen_administered_record)
  end

  def has_conditional_skip?
    !self.antigen_series_dose.conditional_skip.nil?
  end

  # def evaluate_vs_antigen_administered_record(antigen_administered_record)
  #   age_eligible?(@patient.dob)
  #   if !self.eligible
  #     return
  #   end


  # end
end
