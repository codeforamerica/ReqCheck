module AgeCalc
  include TimeCalc
  def validate_date_equal_or_after(first_date, second_date)

  end

  def validate_date_equal_or_before(first_date, second_date)

  end

  def time_string_to_time_hash(time_string)
    # takes a string representing a time or age ("6 months" or "5 years - 6 days") and
    # converts it into a hash with a represention of the time with key value pairs
    # ({months: 6} or {years: 5, days: -6})

    math_type = time_string.include?("-") ? "-" : "+"
    string_array = time_string.split(math_type)
    return_hash   = {}
    string_array.each_with_index do |string_data, index|
      data_array   = string_data.split(" ")
      string_value = index != 0 ? (math_type + data_array[0]) : data_array[0]
      string_key   = data_array[1].to_sym
      return_hash[string_key] = string_value.to_i
    end
    return_hash
  end

  def date_minus_time_period(input_date=Date.today, years: 0, months: 0, weeks: 0, days: 0)
    input_date.years_ago(years).months_ago(months).weeks_ago(weeks).days_ago(days)
  end

  def date_plus_time_period(input_date=Date.today, years: 0, months: 0, weeks: 0, days: 0)
    input_date.years_since(years).months_since(months).weeks_since(weeks).days_since(days)
  end
  
  def create_patient_age_date(cdc_age_string, dob)
    return nil if cdc_age_string == '' or cdc_age_string.nil?
    dob      = convert_to_date(dob)
    age_hash = time_string_to_time_hash(cdc_age_string)
    date_plus_time_period(dob, **age_hash)
  end

  def convert_to_date(input_date)
    input_date = Date.parse(input_date) if input_date.instance_of? String
    input_date = input_date.to_date if input_date.instance_of? ActiveSupport::TimeWithZone
    input_date = input_date.to_date if input_date.instance_of? Time
    input_date = input_date.to_date if input_date.instance_of? DateTime
    return input_date 
  end

end