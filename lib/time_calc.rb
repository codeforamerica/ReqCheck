module TimeCalc
  def date_diff_in_days(first_date, second_date=Date.today)
    first_date  = convert_to_date(first_date)
    second_date = convert_to_date(second_date)
    (second_date - first_date).to_i
  end

  def date_diff_in_years(first_date, second_date=Date.today)
    first_date  = convert_to_date(first_date)
    second_date = convert_to_date(second_date)
    (second_date.to_time.to_s(:number).to_i - first_date.to_time.to_s(:number).to_i)/10e9.to_i
  end

  def date_diff_in_months(first_date, second_date=Date.today)
    first_date  = convert_to_date(first_date)
    second_date = convert_to_date(second_date)
    month_diff = (second_date.year * 12 + second_date.month) - (first_date.year * 12 + first_date.month)
    if second_date.day < first_date.day
      month_diff = month_diff - 1
    end
    month_diff
  end

  def date_diff_in_weeks(first_date, second_date=Date.today)
    first_date  = convert_to_date(first_date)
    second_date = convert_to_date(second_date)
    self.date_diff_in_days(first_date, second_date) / 7
  end

  def detailed_date_diff(first_date, second_date=Date.today)
    first_date      = convert_to_date(first_date)
    second_date     = convert_to_date(second_date)
    years_diff      = self.date_diff_in_years(first_date, second_date)
    new_second_date = second_date.ago(years_diff.years).to_date

    months_diff     = self.date_diff_in_months(first_date, new_second_date)
    new_second_date = new_second_date.ago(months_diff.months).to_date

    weeks_diff      = self.date_diff_in_weeks(first_date, new_second_date)

    # years_string  = years_diff == 1 ? "year" : "years"
    # months_string = months_diff == 1 ? "month" : "months"
    # weeks_string  = weeks_diff == 1 ? "week" : "weeks"
    # "#{years_diff} #{years_string}, #{months_diff} #{months_string}, #{weeks_diff} #{weeks_string}"
    "#{years_diff}y, #{months_diff}m, #{weeks_diff}w"
  end

  def validate_day_diff(days_diff, required_days)
    days_diff > required_days
  end

  def validate_time_period_diff(past_date, future_date=Date.today, years: 0, months: 0, weeks: 0)
    comparison_date = date_minus_time_period(
      future_date, years: years, months: months, weeks: weeks
    )
    past_date <= comparison_date  
  end

  module_function :date_diff_in_days, :date_diff_in_years, :date_diff_in_months,
    :date_diff_in_weeks, :detailed_date_diff, :validate_day_diff, :validate_time_period_diff

  def self.date_minus_time_period(input_date=Date.today, years: 0, months: 0, weeks: 0)
    input_date.years_ago(years).months_ago(months).weeks_ago(weeks)
  end
  
  def self.convert_to_date(input_date)
    input_date = Date.parse(input_date) if input_date.instance_of? String
    input_date = input_date.to_date if input_date.instance_of? ActiveSupport::TimeWithZone
    input_date = input_date.to_date if input_date.instance_of? Time
    input_date = input_date.to_date if input_date.instance_of? DateTime
    return input_date 
  end

end