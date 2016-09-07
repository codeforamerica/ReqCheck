module IntervalEvaluation
  # This logic is defined on page 39 of the CDC logic spec to evaluate the
  # interval (or intervals) between two antigen_administered_records
  include EvaluationBase

  def create_interval_attributes(interval_object, previous_dose_date)
    interval_attrs = {}
    default_values = {
      interval_absolute_min_date: '01/01/1900'.to_date,
      interval_min_date: '01/01/1900'.to_date
    }

    %w(interval_absolute_min interval_min interval_earliest_recommended
    interval_latest_recommended).each do |action|
      date_action                = action + '_date'
      time_differential_string   = interval_object.read_attribute(action)
      interval_date = create_patient_age_date(time_differential_string,
                                              previous_dose_date)
      interval_attrs[date_action.to_sym] = interval_date
    end
    set_default_values(interval_attrs, default_values)
  end

  def evaluate_interval_attrs(interval_date_attrs, date_of_second_dose)
    evaluated_hash = {}
    %w(
      interval_absolute_min_date
      interval_min_date
      interval_earliest_recommended_date
      interval_latest_recommended_date
    ).each do |interval_attr|
      result = nil
      if !interval_date_attrs[interval_attr.to_sym].nil?
        if interval_attr == 'interval_latest_recommended_date'
          result = validate_date_equal_or_before(
                     interval_date_attrs[interval_attr.to_sym],
                     date_of_second_dose
                   )
        else
          result = validate_date_equal_or_after(
                     interval_date_attrs[interval_attr.to_sym],
                     date_of_second_dose
                   )
        end
      end
      result_attr = interval_attr.split('_')[0..-2].join('_')
      evaluated_hash[result_attr.to_sym] = result
    end
    evaluated_hash
  end

  def get_interval_status(interval_evaluation_hash,
                          previous_dose_status_hash=nil)
    interval_status = { evaluated: 'interval' }
    if interval_evaluation_hash[:interval_absolute_min] == false
      interval_status[:status]  = 'invalid'
      interval_status[:details] = 'too_soon'
    elsif interval_evaluation_hash[:interval_min] == false
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
        interval_status[:status]  = 'valid'
        interval_status[:details]  = 'grace_period'
      else
        interval_status[:status]  = 'invalid'
        interval_status[:details] = 'too_soon'
      end
    else
      interval_status[:status]  = 'valid'
      interval_status[:details]  = 'on_schedule'
    end
    interval_status
  end

  def evaluate_interval(interval_object,
                        previous_dose_date:,
                        date_of_dose:,
                        previous_dose_status_hash: nil)
    interval_attrs = create_interval_attributes(interval_object,
                                                previous_dose_date)
    interval_evaluation = evaluate_interval_attrs(interval_attrs,
                                                  date_of_dose)
    get_interval_status(interval_evaluation, previous_dose_status_hash)
  end
end
