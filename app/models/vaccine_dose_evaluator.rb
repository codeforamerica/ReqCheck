class VaccineDoseEvaluator
  include ActiveModel::Model

  attr_accessor :antigen_administered_record, :target_dose, :evaluation_status, :target_dose_status

  def initialize(antigen_administered_record:, target_dose:)
    @antigen_administered_record = antigen_administered_record
    @target_dose 				         = target_dose
    # @evaluation_status           = nil
    # @target_dose_status          = nil
  end

    # Evaluate Dose Administered Condition 
    # Evaluate Conditional Skip
    # Evaluate Age
    # Evaluate Interval
    # Evaluate Allowable Interval
    # Evaluate Live Virus Conflict
    # Evaluate Preferable Vaccine Administered
    # Evaluate Allowable Vaccine Administered
    # Evaluate Gender
    # Satisfy Target Dose 

  def evaluate_dose_administered_condition

  end

  def evaluate_conditional_skip

  end

  def evaluate_age

  end

  def evaluate_interval

  end

  def evaluate_allowable_interval

  end

  def evaluate_live_virus_conflict

  end

  def evaluate_preferable_vaccine_administered

  end

  def evaluate_allowable_vaccine_administered


  end

  def evaluate_gender

  end

  def evaluate_target_dose_satisfied

  end


end
