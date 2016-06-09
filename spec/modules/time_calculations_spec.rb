require 'rails_helper'
require 'time_calc'

RSpec.describe TimeCalc do
  before do
    new_time = Time.local(2016, 1, 3, 10, 0, 0)
    Timecop.freeze(new_time)
  end

  after do
    Timecop.return
  end
  
  describe "#convert_to_date" do
    it "takes a string and converts it to a date" do
      string_date   = 1.years.ago.to_date.strftime("%m/%d/%Y")
      expected_date = Date.parse(string_date)
      result_date   = TimeCalc.convert_to_date(string_date)
      expect(result_date).to eq(expected_date)
      expect(result_date.class.name).to eq("Date")
    end

    it "takes an activerecord time_with_zone and converts it to a date" do
      active_record_timewzone = 1.year.ago
      expected_date           = active_record_timewzone.to_date
      result_date = TimeCalc.convert_to_date(active_record_timewzone)
      expect(result_date).to eq(expected_date)
      expect(result_date.class.name).to eq("Date")
    end
    
    it "can take take a time and remove the time zone" do
        time_w_zone   = 1.year.ago.to_time
        expected_date = time_w_zone.to_date
        result_date   = TimeCalc.convert_to_date(time_w_zone)
        expect(result_date).to eq(expected_date)
        expect(result_date.class.name).to eq("Date")
    end
    it "can take take a datetime and convert it to date" do
      date_datetime   = 1.year.ago.to_datetime
      expected_date = date_datetime.to_date
      result_date   = TimeCalc.convert_to_date(date_datetime)
      expect(result_date).to eq(expected_date)
      expect(result_date.class.name).to eq("Date")
    end
  end


  describe "#date_diff_in_days" do
    context "in comparison to internal ruby calculations" do
      it "tests ruby's internal calculation with leap years" do
        historical_date   = 22.year.ago.to_date
        today_date      = Date.today
        date_diff       = (today_date - historical_date).to_i
        # 1996, 2000, 2004, 2008, 2012, 2016
        expect(date_diff).to eq((365 * 22) + 5)
      end
      it "accurately calculates the diff from today" do
        historical_date = 5.year.ago.to_date
        today_date      = Date.today
        func_date_dif   = TimeCalc.date_diff_in_days(historical_date, today_date)
        ruby_date_diff  = (today_date - historical_date).to_i
        expect(func_date_dif).to eq(ruby_date_diff)
      end
    end
    context "with only one input date" do
      it "defaults date 2 to Date.today" do
        input_date = in_pst(5.years.ago)
        age_days = TimeCalc.date_diff_in_days(input_date)
        expect(age_days).to be(5 * 365 + 1)
      end
      it "can accept a string date" do
        string_date = 1.years.ago.to_s
        age_days = TimeCalc.date_diff_in_days(string_date)
        expect(age_days).to be(365)
      end
    end

    context "with multiple dates" do
      it "returns the difference between the two dates in days" do
        input_date  = in_pst(5.years.ago).to_date
        input_date2 = 4.years.ago.to_date
        age_days    = TimeCalc.date_diff_in_days(input_date, input_date2)
        expect(age_days).to be(365)
      end
      it "can accept a string date" do
        string_date  = in_pst(5.years.ago).to_s
        string_date2 = 4.years.ago.to_s
        age_days = TimeCalc.date_diff_in_days(string_date, string_date2)
        expect(age_days).to be(365)
      end
      it "can accept date_time object" do
        string_date  = in_pst(5.years.ago).to_datetime
        string_date2 = 4.years.ago.to_datetime
        age_days = TimeCalc.date_diff_in_days(string_date, string_date2)
        expect(age_days).to be(365)
      end
      it "can accept time object" do
        string_date  = in_pst(5.years.ago)
        string_date2 = 4.years.ago
        age_days = TimeCalc.date_diff_in_days(string_date, string_date2)
        expect(age_days).to be(365)
      end
    end
  end

  describe "#date_diff_in_years" do
    context "with only one input date" do
      it "defaults date 2 to Date.today" do
        input_date = in_pst(5.years.ago)
        age_in_years = TimeCalc.date_diff_in_years(input_date)
        expect(age_in_years).to be(5)
      end
      it "can accept a string date" do
        string_date = 1.years.ago.to_s
        age_in_years = TimeCalc.date_diff_in_years(string_date)
        expect(age_in_years).to be(1)
      end
    end

    context "with multiple dates" do
      it "returns the difference between the two dates in days" do
        input_date  = in_pst(5.years.ago).to_date
        input_date2 = 4.years.ago.to_date
        age_in_years    = TimeCalc.date_diff_in_years(input_date, input_date2)
        expect(age_in_years).to be(1)
      end
      it "can accept a string date" do
        string_date  = in_pst(5.years.ago).to_s
        string_date2 = 4.years.ago.to_s
        age_in_years = TimeCalc.date_diff_in_years(string_date, string_date2)
        expect(age_in_years).to be(1)
      end
      it "can accept date_time object" do
        string_date  = in_pst(5.years.ago).to_datetime
        string_date2 = 4.years.ago.to_datetime
        age_in_years = TimeCalc.date_diff_in_years(string_date, string_date2)
        expect(age_in_years).to be(1)
      end
      it "can accept time object" do
        string_date  = in_pst(5.years.ago)
        string_date2 = 4.years.ago
        age_in_years = TimeCalc.date_diff_in_years(string_date, string_date2)
        expect(age_in_years).to be(1)
      end
    end
  end

  describe "#validate_day_diff" do
    it "takes an day_diff and required_days and returns boolean" do
      day_diff = 100
      required_days = 80
      expect(TimeCalc.validate_day_diff(day_diff, required_days)).to be(true)
    end

    it "returns true when the day_diff is higher than required days" do
      day_diff = 100
      required_days = 80
      expect(TimeCalc.validate_day_diff(day_diff, required_days)).to be(true)
    end
    
    it "returns false when the day_diff is lower than required days" do
      day_diff = 60
      required_days = 80
      expect(TimeCalc.validate_day_diff(day_diff, required_days)).to be(false)
    end
  end

  describe "#date_minus_time_period" do
    before(:each) do
      new_time = Time.local(2015, 7, 15, 10, 0, 0)
      Timecop.freeze(new_time)
    end
    after(:each) do
      Timecop.return
    end
    it "takes an input date and a collection of different time units" do
      years, months, weeks = 1, 2, 2
      start_date    = Date.today
      expected_date = Date.new(2014, 5, 1)
      expect(TimeCalc.date_minus_time_period(
        start_date, {years: years, months: months, weeks: weeks}
      )).to eq(expected_date)
    end
    it "accounts for the leap year" do
      new_time = Time.local(2016, 3, 3, 10, 0, 0)
      Timecop.freeze(new_time) do
        years, months, weeks = 1, 0, 2
        start_date    = Date.today
        expected_date = Date.new(2015, 2, 17)
        expect(TimeCalc.date_minus_time_period(
          start_date, {years: years, months: months, weeks: weeks}
        )).to eq(expected_date)
      end
    end
    it "calculates months differently than just 4 weeks" do
      months, weeks = 2, 8
      start_date    = Date.today
      expected_date1 = Date.new(2015, 5, 15)
      expected_date2 = Date.new(2015, 5, 20)
      expect(TimeCalc.date_minus_time_period(start_date, months: months)).to eq(expected_date1)
      expect(TimeCalc.date_minus_time_period(start_date, weeks: weeks)).to eq(expected_date2)
    end
  end

  describe "#validate_time_period_diff" do
    before(:each) do
      new_time = Time.local(2015, 7, 15, 10, 0, 0)
      Timecop.freeze(new_time)
    end
    after(:each) do
      Timecop.return
    end
    it "can take one date and a collection of different time units" do
      years, months, weeks = 0, 6, 0
      past_date          = Date.new(2015, 5, 15)
      expect(
        TimeCalc.validate_time_period_diff(past_date, years: years, months: months, weeks: weeks)
      ).to eq(false)
    end

    it "can take two dates and a collection of different time units" do
      years, months, weeks   = 0, 6, 0
      past_date            = Date.new(2015, 1, 15)
      future_date          = Date.new(2015, 8, 15)
      expect(
        TimeCalc.validate_time_period_diff(
          past_date, future_date, years: years, months: months, weeks: weeks
        )
      ).to eq(true)
    end
    
# => EXACT DATES, TRUE OR FALSE?
# => What about     
    it "returns true when a date is exactly on the day differential" do
      years, months, weeks   = 0, 1, 0
      past_date            = Date.new(2015, 1, 15)
      future_date          = Date.new(2015, 2, 15)
      expect(
        TimeCalc.validate_time_period_diff(
          past_date, future_date, years: years, months: months, weeks: weeks
        )
      ).to eq(true)
    end
  end

end
