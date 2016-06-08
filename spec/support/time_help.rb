module TimeHelp
  def in_pst(time_date)
    time_date.in_time_zone("Pacific Time (US & Canada)").to_s.to_date
  end
end