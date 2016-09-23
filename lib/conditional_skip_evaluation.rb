module ConditionalSkipEvaluation
  include EvaluationBase
  include ConditionalSkipConditionEvaluation
  # Does the Conditional Skip Series Group identify a Series Group with at
  # least one series with a status of “Complete”?
  #   I believe this means that if it completes one of the series in the group,
  #   then it is valid. If not, then it is not and should not be included - But is
  #   this true?

  def get_conditional_skip_set_status(condition_logic,
                                      condition_statuses_array)
    if condition_statuses_array == []
      raise ArgumentError.new('Condition Status Array cannot be empty')
    end
    status_hash = { evaluated: 'conditional_skip_set' }
    status_hash[:evaluation_status] = nil

    # conditional_eval = Proc.new {|condition_status| condition_status[:evaluation_status] == 'condition_met' }
    met, not_met = condition_statuses_array.partition do |condition_status|
      condition_status[:evaluation_status] == 'condition_met'
    end
    if condition_logic == 'and'
      if not_met.length.zero?
        status_hash[:evaluation_status] = 'set_met'
      else
        status_hash[:evaluation_status] = 'set_not_met'
      end
    elsif condition_logic == 'or'
      if !met.length.zero?
        status_hash[:evaluation_status] = 'set_met'
      else
        status_hash[:evaluation_status] = 'set_not_met'
      end
    end
    status_hash[:met_conditions] = met
    status_hash[:not_met_conditions] = not_met
    status_hash
  end

  def get_conditional_skip_status(set_logic, set_statuses_array)
    if set_statuses_array == []
      raise ArgumentError.new('Set Status Array cannot be empty')
    end
    status_hash = { evaluated: 'conditional_skip' }
    status_hash[:evaluation_status] = nil

    met, not_met = set_statuses_array.partition do |set_status|
      set_status[:evaluation_status] == 'set_met'
    end

    if set_logic == 'and' || set_logic == 'n/a'
      if not_met.length.zero?
        status_hash[:evaluation_status] = 'conditional_skip_met'
      else
        status_hash[:evaluation_status] = 'conditional_skip_not_met'
      end
    elsif set_logic == 'or'
      if !met.length.zero?
        status_hash[:evaluation_status] = 'conditional_skip_met'
      else
        status_hash[:evaluation_status] = 'conditional_skip_not_met'
      end
    end
    status_hash[:met_sets] = met
    status_hash[:not_met_sets] = not_met
    status_hash
  end

  def evaluate_conditional_skip_set(set_object,
                                    patient_dob:,
                                    date_of_dose:,
                                    patient_vaccine_doses: [],
                                    satisfied_target_doses: [])
    condition_statuses = set_object.conditions.map do |condition_object|
      evaluate_conditional_skip_condition(
        condition_object,
        patient_dob: patient_dob,
        date_of_dose: date_of_dose,
        patient_vaccine_doses: patient_vaccine_doses,
        satisfied_target_doses: satisfied_target_doses
      )
    end
    get_conditional_skip_set_status(set_object.condition_logic,
                                    condition_statuses)
  end


  def evaluate_conditional_skip(conditional_skip_object,
                                patient_dob:,
                                date_of_dose:,
                                patient_vaccine_doses: [],
                                satisfied_target_doses: [])
    set_statuses = conditional_skip_object.sets.map do |set_object|
      evaluate_conditional_skip_set(
        set_object,
        patient_dob: patient_dob,
        date_of_dose: date_of_dose,
        patient_vaccine_doses: patient_vaccine_doses,
        satisfied_target_doses: satisfied_target_doses
      )
    end
    get_conditional_skip_status(conditional_skip_object.set_logic,
                                set_statuses)
  end

end
