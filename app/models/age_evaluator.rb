class AgeEvaluator < BaseEvaluator

  def default_values
    {
      max_age_date: '12/31/2999'.to_date,
      min_age_date: '01/01/1900'.to_date,
      absolute_min_age_date: '01/01/1900'.to_date
    }
  end

  def minimum_date_attributes
    %w(absolute_min_age min_age earliest_recommended_age)
  end

  def maximum_date_attributes
    %w(latest_recommended_age max_age)
  end

  def build_attributes(antigen_administered_record)
    patient_dob = target_dose.patient.dob
    age_attrs = create_calculated_dates(base_attributes,
                                        target_dose,
                                        patient_dob)
    set_default_values(age_attrs)
  end

  def custom_non_date_attributes()
  end

  def analyze_attributes(attributes)
    evaluated_hash = {}
    %w(
      absolute_min_age_date min_age_date earliest_recommended_age_date
      latest_recommended_age_date max_age_date
    ).each do |age_attr|
      result = nil
      unless attributes[age_attr.to_sym].nil?
        if %w(latest_recommended_age_date max_age_date).include?(age_attr)
          result = validate_date_equal_or_before(attributes[age_attr.to_sym],
                                                 date_of_dose)
        else
          result = validate_date_equal_or_after(attributes[age_attr.to_sym],
                                                date_of_dose)
        end
      end
      result_attr = date_attr_to_original(age_attr)
      evaluated_hash[result_attr.to_sym] = result
    end
    evaluated_hash
  end

  def get_evaluation(analyzed_attributes, evaluation)
    # As described on page 38 (TABLE 4 - 12) in the CDC logic specifications
    # age_status = {record: antigen_administered_record}
    evaluation.set_evaluated('age')

    if analyzed_attributes[:absolute_min_age] == false
      evaluation.set_evaluation_status('not_valid')
      evaluation.set_details('too_young')
    elsif analyzed_attributes[:min_age] == false
      has_previous_dose = !previous_dose_status_hash.nil?
      is_valid = true

      if has_previous_dose
        previous_dose_not_valid =
          previous_dose_status_hash[:evaluation_status] == 'not_valid'
        previous_dose_reason  = previous_dose_status_hash[:reason]
        age_or_interval = ['age', 'interval'].include?(previous_dose_reason)

        if previous_dose_not_valid && age_or_interval
          is_valid = false
        end
      end
      if is_valid
        evaluation.set_evaluation_status('valid')
        evaluation.set_details('grace_period')
      else
        evaluation.set_evaluation_status('not_valid')
        evaluation.set_details('too_young')
      end

    elsif analyzed_attributes[:max_age] == false
      # Should we include extraneous on this as well? Where?
      evaluation.set_evaluation_status('not_valid')
      evaluation.set_details('too_old')
    else
      evaluation.set_evaluation_status('valid')
      evaluation.set_details('on_schedule')
    end
    evaluation
  end
end
