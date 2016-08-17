module TimeCalc
  def date_diff_in_days(first_date, second_date = Date.today)
    first_date  = convert_to_date(first_date)
    second_date = convert_to_date(second_date)
    (second_date - first_date).to_i
  end

  def date_diff_in_years(first_date, second_date = Date.today)
    first_date  = convert_to_date(first_date)
    second_date = convert_to_date(second_date)
    (second_date.to_time.to_s(:number).to_i - first_date.to_time.to_s(:number).to_i)/10e9.to_i
  end

  def date_diff_in_months(first_date, second_date = Date.today)
    first_date  = convert_to_date(first_date)
    second_date = convert_to_date(second_date)
    month_diff  = (second_date.year * 12 + second_date.month) -
                  (first_date.year * 12 + first_date.month)
    month_diff -= 1 if second_date.day < first_date.day
    month_diff
  end

  def date_diff_in_weeks(first_date, second_date = Date.today)
    first_date  = convert_to_date(first_date)
    second_date = convert_to_date(second_date)
    date_diff_in_days(first_date, second_date) / 7
  end

  def detailed_date_diff(first_date, second_date = Date.today)
    first_date      = convert_to_date(first_date)
    second_date     = convert_to_date(second_date)
    years_diff      = date_diff_in_years(first_date, second_date)
    new_second_date = second_date.ago(years_diff.years).to_date

    months_diff     = date_diff_in_months(first_date, new_second_date)
    new_second_date = new_second_date.ago(months_diff.months).to_date

    weeks_diff      = date_diff_in_weeks(first_date, new_second_date)

    # years_string  = years_diff == 1 ? "year" : "years"
    # months_string = months_diff == 1 ? "month" : "months"
    # weeks_string  = weeks_diff == 1 ? "week" : "weeks"
    # "#{years_diff} #{years_string}, #{months_diff} #{months_string},
    # #{weeks_diff} #{weeks_string}"
    "#{years_diff}y, #{months_diff}m, #{weeks_diff}w"
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
      string_key    = data_array[1].to_sym
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

  def convert_to_date(input_date)
    input_date = Date.parse(input_date) if input_date.instance_of? String
    convertible = [ActiveSupport::TimeWithZone, Time, DateTime].any? do |klass|
      input_date.instance_of? klass
    end
    input_date = input_date.to_date if convertible
    input_date
  end
end
