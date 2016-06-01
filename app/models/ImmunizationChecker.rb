class ImmunizationChecker
  

  def date_diff_in_days(first_date, second_date=Date.today)
    first_date  = Date.parse(first_date) if first_date.instance_of? String
    first_date  = first_date.to_date if first_date.instance_of? ActiveSupport::TimeWithZone
    second_date = Date.parse(second_date) if second_date.instance_of? String
    second_date = second_date.to_date if second_date.instance_of? ActiveSupport::TimeWithZone
    (((second_date - first_date) / 365).to_i * 365)
  end

  def validate_day_diff(date_diff, required_days)
    date_diff > required_days
  end




end