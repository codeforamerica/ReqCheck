module TimeCalc
  def date_diff_in_days(first_date, second_date=Date.today)
    first_date  = convert_to_date(first_date)
    second_date = convert_to_date(second_date)
    (((second_date - first_date) / 365).to_i * 365)
  end

  def date_diff_in_years(first_date, second_date=Date.today)
    first_date  = convert_to_date(first_date)
    second_date = convert_to_date(second_date)
    (((second_date - first_date) / 365).to_i)
  end

  def validate_day_diff(days_diff, required_days)
    days_diff > required_days
  end

  module_function :date_diff_in_days, :date_diff_in_years, :validate_day_diff
  
  def self.convert_to_date(input_date)
    input_date = Date.parse(input_date) if input_date.instance_of? String
    input_date = input_date.to_date if input_date.instance_of? ActiveSupport::TimeWithZone
    return input_date 
  end

end