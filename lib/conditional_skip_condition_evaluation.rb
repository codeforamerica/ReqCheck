module ConditionalSkipConditionEvaluation
  include EvaluationBase
  include DoseCountEvaluation

  def create_conditional_skip_condition_attributes(
    condition_object,
    previous_dose_date,
    dob
  )
    condition_attrs = {}
    condition_attrs[:assessment_date] = Date.today.to_date
    condition_attrs[:condition_id]    = condition_object.condition_id
    condition_attrs[:condition_type]  = condition_object.condition_type

    time_attributes = %w(begin_age end_age)
    condition_attrs = create_calculated_dates(time_attributes,
                                              condition_object,
                                              dob,
                                              condition_attrs)
    if previous_dose_date.nil? &&
       (!condition_object.interval.nil? &&
        condition_object.interval != '')
       raise ArgumentError.new('No previous dose date and conditional skip ' \
                               'condition interval required')
    else
      expected_interval_date = create_patient_age_date(
        condition_object.interval,
        previous_dose_date
      )
      condition_attrs[:interval_date] = expected_interval_date
    end

    ['start_date', 'end_date'].each do |attribute|
      condition_attribute = condition_object.read_attribute(attribute)
      if !condition_attribute.nil? && condition_attribute != ''
        condition_attrs[attribute.to_sym] = Date.strptime(condition_attribute,
                                                          "%Y%m%d")
      else
        condition_attrs[attribute.to_sym] = nil
      end
    end
    condition_attrs[:dose_count] = if condition_object.dose_count == '' ||
                                      condition_object.dose_count.nil?
                                        nil
                                   else
                                      condition_object.dose_count.to_i
                                   end
    condition_attrs[:dose_type]        = condition_object.dose_type
    condition_attrs[:dose_count_logic] = condition_object.dose_count_logic
    vaccine_types = if !condition_object.vaccine_types.nil?
                      condition_object.vaccine_types.split(";")
                    else
                      []
                    end
    condition_attrs[:vaccine_types] = vaccine_types
    condition_attrs
  end

  def evaluate_conditional_skip_condition_attributes(
    condition_attrs,
    date_of_dose,
    satisfied_target_doses: [],
    patient_vaccine_doses: []
  )
    # TABLE 6-7 CONDITIONAL TYPE OF COMPLETED SERIES – IS THE CONDITION MET?
    # How to evaluate this component?
    evaluated_hash = {}
    %w(
      begin_age_date
      start_date
      end_age_date
      end_date
      interval_date
    ).each do |condition_attr|
      result = nil
      if !condition_attrs[condition_attr.to_sym].nil?
        if ['end_age_date', 'end_date'].include?(condition_attr)
          result = validate_date_equal_or_before(
                     condition_attrs[condition_attr.to_sym],
                     date_of_dose
                   )
        else
          result = validate_date_equal_or_after(
                     condition_attrs[condition_attr.to_sym],
                     date_of_dose
                   )
        end
      end
      name_array = condition_attr.split('_')
      result_attr = if name_array.length == 3
                      name_array[0..-2].join('_')
                    else
                      condition_attr
                    end
      evaluated_hash[result_attr.to_sym] = result
    end

    if condition_attrs[:dose_type].nil? || condition_attrs[:dose_type] == ''
      evaluated_hash[:dose_count_valid] = nil
    else
      input_doses = if condition_attrs[:dose_type] == 'total'
                      patient_vaccine_doses
                    else
                      satisfied_target_doses
                    end
      actual_dose_count = calculate_count_of_vaccine_doses(input_doses,
        condition_attrs[:vaccine_types],
        begin_age_date: condition_attrs[:begin_age_date],
        end_age_date: condition_attrs[:end_age_date],
        start_date: condition_attrs[:start_date],
        end_date: condition_attrs[:end_date],
        dose_type: condition_attrs[:dose_type]
      )

      dose_count_result = evaluate_vaccine_dose_count(
        condition_attrs[:dose_count_logic],
        condition_attrs[:dose_count],
        actual_dose_count
      )
      evaluated_hash[:dose_count_valid] = dose_count_result
    end

    evaluated_hash
  end

  def get_conditional_skip_condition_status(evaluation_hash)
    status_hash = { evaluated: 'conditional_skip_condition' }
    status_hash[:evaluation_status] = nil

    if evaluation_hash[:begin_age] == false ||
       evaluation_hash[:end_age] == false
      status_hash[:evaluation_status] = 'condition_not_met'
      status_hash[:reason] = 'age'
    elsif evaluation_hash[:begin_age] == true ||
       evaluation_hash[:end_age] == true
      status_hash[:evaluation_status] = 'condition_met'
      status_hash[:reason] = 'age'
    end
    if status_hash[:evaluation_status] != 'condition_not_met'
      if evaluation_hash[:start_date] == false ||
         evaluation_hash[:end_date] == false
        status_hash[:evaluation_status] = 'condition_not_met'
        status_hash[:reason] = 'dose_timing'
      elsif status_hash[:evaluation_status].nil? &&
            (evaluation_hash[:start_date] == true ||
             evaluation_hash[:end_date] == true)
        status_hash[:evaluation_status] = 'condition_met'
        status_hash[:reason] = 'dose_timing'
      end
    end
    if status_hash[:evaluation_status] != 'condition_not_met'
      if evaluation_hash[:interval_date] == false ||
         evaluation_hash[:end_date] == false
        status_hash[:evaluation_status] = 'condition_not_met'
        status_hash[:reason] = 'interval'
      elsif status_hash[:evaluation_status].nil? &&
            (evaluation_hash[:interval_date] == true ||
             evaluation_hash[:end_date] == true)
        status_hash[:evaluation_status] = 'condition_met'
        status_hash[:reason] = 'interval'
      end
    end
    status_hash
  end

  def evaluate_conditional_skip_condition(
    condition_object,
    patient_dob:,
    date_of_dose:,
    patient_vaccine_doses: [],
    satisfied_target_doses: []
  )
    date_of_previous_dose = if satisfied_target_doses[-1]
                              satisfied_target_doses[-1].date_administered
                            else
                              nil
                            end
    condition_attrs = create_conditional_skip_condition_attributes(
      condition_object,
      date_of_previous_dose,
      patient_dob
    )
    condition_evaluation = evaluate_conditional_skip_condition_attributes(
      condition_attrs,
      date_of_dose
    )
    get_conditional_skip_condition_status(condition_evaluation)
  end
end
