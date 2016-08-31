module EvaluationBase
  include AgeCalc

  def create_calculated_dates(time_attributes,
                              read_object,
                              start_date,
                              result_hash={})
    time_attributes.each do |atrribute|
      date_atrribute  = atrribute + '_date'
      time_string     = read_object.read_attribute(atrribute)
      calculated_date = create_patient_age_date(time_string, start_date)
      result_hash[date_atrribute.to_sym] = calculated_date
    end
    result_hash
  end

  def set_default_values(return_hash, default_hash={})
    default_hash.each do |default_value_key, default_value|
      current_value = return_hash[default_value_key]
      if current_value.nil? || current_value == ''
        return_hash[default_value_key] = default_value
      end
    end
    return_hash
  end
end
