module AgeCalc
  def validate_date_equal_or_after(base_date, evaluated_date)
    base_date <= evaluated_date
  end

  def validate_date_equal_or_before(base_date, evaluated_date)
    base_date >= evaluated_date
  end

  def time_string_to_time_hash(time_string)
    # takes a string representing a time or age
    # ("6 months" or "5 years - 6 days") and converts
    # it into a hash with a represention of the time with key value pairs
    # ({months: 6} or {years: 5, days: -6})
    second_operator = time_string.include?('-') ? '-' : '+'
    string_array = time_string.split(second_operator)
    return_hash  = {}
    string_array.each_with_index do |string_data, index|
      math_operator = index.zero? ? '+' : second_operator
      data_array    = string_data.split(' ')

      if %w(month week year day).include?(data_array[1])
        data_array[1] = data_array[1] + 's'
      end

      string_key = data_array[1].to_sym
      return_hash[string_key] = (math_operator + data_array[0]).to_i
    end
    return_hash
  end

  def date_minus_time_period(input_date = Date.today,
                             years: 0,
                             months: 0,
                             weeks: 0,
                             days: 0)
    input_date.years_ago(years)
              .months_ago(months)
              .weeks_ago(weeks)
              .days_ago(days)
  end

  def date_plus_time_period(input_date = Date.today,
                            years: 0,
                            months: 0,
                            weeks: 0,
                            days: 0)
    input_date.years_since(years)
              .months_since(months)
              .weeks_since(weeks)
              .days_since(days)
  end

  def create_calculated_date(cdc_age_string, dob)
    # Need to add tests for age_calc or keep it in time_calc
    # Especially with duplicate methods
    return nil if cdc_age_string == '' || cdc_age_string.nil?
    dob      = convert_to_date(dob)
    age_hash = time_string_to_time_hash(cdc_age_string)
    date_plus_time_period(dob, **age_hash)
  end

  def convert_to_date(input_date)
    input_date = Date.parse(input_date) if input_date.instance_of? String
    convertible = [ActiveSupport::TimeWithZone, Time, DateTime].any? do |klass|
      input_date.instance_of? klass
    end
    input_date = input_date.to_date if convertible
    input_date
  end
end
