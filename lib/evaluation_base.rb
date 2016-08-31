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

end
