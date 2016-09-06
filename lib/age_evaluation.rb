module AgeEvaluation
  include EvaluationBase

  def create_age_attributes(evaluation_antigen_series_dose, patient_dob)
    age_attrs = {}
    default_values = {
      max_age_date: '12/31/2999'.to_date,
      min_age_date: '01/01/1900'.to_date,
      absolute_min_age_date: '01/01/1900'.to_date
    }
    [
      'absolute_min_age', 'min_age', 'earliest_recommended_age',
      'latest_recommended_age', 'max_age'
    ].each do |action|
      date_action  = action + '_date'
      age_string   = evaluation_antigen_series_dose.read_attribute(action)
      patient_date = create_patient_age_date(age_string, patient_dob)
      age_attrs[date_action.to_sym] = patient_date
    end
    set_default_values(age_attrs, default_values)
  end

  def evaluate_age_attributes(age_date_attrs, date_of_dose)
    evaluated_hash = {}
    [
      'absolute_min_age_date',
      'min_age_date',
      'earliest_recommended_age_date',
      'latest_recommended_age_date',
      'max_age_date'
    ].each do |age_attr|
      result = nil
      if !age_date_attrs[age_attr.to_sym].nil?
        if ['latest_recommended_age_date', 'max_age_date'].include?(age_attr)
          result = validate_date_equal_or_before(
                     age_date_attrs[age_attr.to_sym],
                     date_of_dose
                   )
        else
          result = validate_date_equal_or_after(age_date_attrs[age_attr.to_sym],
                                                date_of_dose)
        end
      end
      result_attr = age_attr.split('_')[0..-2].join('_')
      evaluated_hash[result_attr.to_sym] = result
    end
    evaluated_hash
  end

  def get_age_status(age_evaluation_hash,
                     # antigen_administered_record,
                     previous_dose_status_hash=nil)
    # As described on page 38 (TABLE 4 - 12) in the CDC logic specifications
    # age_status = {record: antigen_administered_record}
    # age_status = {record: antigen_administered_record}
    age_status = { evaluated: 'age' }
    if age_evaluation_hash[:absolute_min_age] == false
      age_status[:status]  = 'invalid'
      age_status[:details] = 'too_young'
    elsif age_evaluation_hash[:min_age] == false
      has_previous_dose = !previous_dose_status_hash.nil?
      is_valid = true

      if has_previous_dose
        previous_dose_invalid = previous_dose_status_hash[:status] == 'invalid'
        previous_dose_reason  = previous_dose_status_hash[:reason]
        age_or_interval = ['age', 'interval'].include?(previous_dose_reason)

        if previous_dose_invalid && age_or_interval
          is_valid = false
        end
      end

      if is_valid
        age_status[:status]  = 'valid'
        age_status[:details]  = 'grace_period'
      else
        age_status[:status]  = 'invalid'
        age_status[:details] = 'too_young'
      end

    elsif age_evaluation_hash[:max_age] == false
      # Should we include extraneous on this as well? Where?
      age_status[:status]  = 'invalid'
      age_status[:details] = 'too_old'
    else
      age_status[:status]  = 'valid'
      age_status[:details]  = 'on_schedule'
    end
    age_status
  end

  def evaluate_age(evaluation_antigen_series_dose,
                   patient_dob:,
                   date_of_dose:,
                   previous_dose_status_hash: nil)
    age_attrs = create_age_attributes(evaluation_antigen_series_dose,
                                      patient_dob)
    age_evaluation = evaluate_age_attributes(age_attrs, date_of_dose)
    get_age_status(age_evaluation, previous_dose_status_hash)
  end
end
