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
      interval_status[:evaluation_status]  = 'not_valid'
      interval_status[:details] = 'too_soon'
    elsif interval_evaluation_hash[:interval_min] == false
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
        interval_status[:evaluation_status]  = 'valid'
        interval_status[:details]  = 'grace_period'
      else
        interval_status[:evaluation_status]  = 'not_valid'
        interval_status[:details] = 'too_soon'
      end
    else
      interval_status[:evaluation_status]  = 'valid'
      interval_status[:details]  = 'on_schedule'
    end
    interval_status
  end

  def evaluate_interval(interval_object,
                        date_of_dose:,
                        comparison_dose_date:,
                        previous_dose_status_hash: nil)
    interval_attrs = create_interval_attributes(interval_object,
                                                comparison_dose_date)
    interval_evaluation = evaluate_interval_attrs(interval_attrs,
                                                  date_of_dose)
    get_interval_status(interval_evaluation, previous_dose_status_hash)
  end

  def get_target_dose_date(target_dose_dates, target_dose_number)
    if !target_dose_number.is_a? Integer
      raise "Invalid target_dose_number: #{target_dose_number}"
    end
    target_dose_index = (target_dose_number - 1)
    target_dose_date = target_dose_dates.fetch(target_dose_index, false)
    if target_dose_dates == false
      raise "Invalid target_dose_dates: #{target_dose_dates}. " \
            "target_dose_number #{taret_dose_number} out of range."
    end
    return target_dose_date
  end

  def get_most_recent_dose_date_by_cvx_code(vaccine_doses,
                                            cvx_code)
    if !cvx_code.is_a? Integer
      raise "Invalid cvx_code: #{cvx_code}"
    end
    recent_vaccine_dose = vaccine_doses
      .sort_by(&:date_administered)
      .reverse!
      .find do |vaccine_dose|
        vaccine_dose.cvx_code == cvx_code
      end
    if recent_vaccine_dose == nil
      raise "Invalid vaccine_doses: #{vaccine_doses}. " \
            "cvx_code #{cvx_code} cannot be found."
    end
    return recent_vaccine_dose.date_administered
  end

  def evaluate_intervals(interval_objects,
                         date_of_dose:,
                         previous_dose_date:,
                         patient_vaccine_doses: [],
                         satisfied_target_dose_dates: [],
                         previous_dose_status_hash: nil)
    ## This currently does not account for the status hashes of the different
    #  doses that are not the immediate previous dose (target_dose_number and
    #  most_recent by cvx_code)
    ## This currently will error if the previous satisfied target dose is not
    #  found for the target_dose_number OR the patient_vaccine_dose is not
    #  found for the recent_cvx_code
    #
    #  With target dose spec, need to implement this into the evaluation
    #  but currently do not know how to get the target doses with the statuses
    #  and the vaccine doses
    interval_objects.map do |interval_object|
      comparison_dose_date = '01/01/1900'.to_date
      if interval_object.interval_type == 'from_previous'
        comparison_dose_date = previous_dose_date
      elsif interval_object.interval_type == 'from_target_dose'
        comparison_dose_date =
          get_target_dose_date(satisfied_target_dose_dates,
                               interval_object.target_dose_number)
      elsif interval_object.interval_type == 'from_most_recent'

      end
      evaluate_interval(interval_object,
                        date_of_dose: date_of_dose,
                        comparison_dose_date: comparison_dose_date,
                        previous_dose_status_hash: previous_dose_status_hash)
    end
  end
end
