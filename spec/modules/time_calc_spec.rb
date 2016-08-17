require 'rails_helper'
require 'time_calc'

RSpec.describe TimeCalc do
  let(:time_calc_obj) do
    time_calc_obj = Object.new
    time_calc_obj.extend(TimeCalc)
  end
  before do
    new_time = Time.local(2016, 1, 3, 10, 0, 0)
    Timecop.freeze(new_time)
  end

  after do
    Timecop.return
  end

  describe '#convert_to_date' do
    it 'takes a string and converts it to a date' do
      string_date   = 1.years.ago.to_date.strftime('%m/%d/%Y')
      expected_date = Date.parse(string_date)
      result_date   = time_calc_obj.convert_to_date(string_date)
      expect(result_date).to eq(expected_date)
      expect(result_date.class.name).to eq('Date')
    end

    it 'takes an activerecord time_with_zone and converts it to a date' do
      active_record_timewzone = 1.year.ago
      expected_date           = active_record_timewzone.to_date
      result_date = time_calc_obj.convert_to_date(active_record_timewzone)
      expect(result_date).to eq(expected_date)
      expect(result_date.class.name).to eq('Date')
    end

    it 'can take take a time and remove the time zone' do
      time_w_zone   = 1.year.ago.to_time
      expected_date = time_w_zone.to_date
      result_date   = time_calc_obj.convert_to_date(time_w_zone)
      expect(result_date).to eq(expected_date)
      expect(result_date.class.name).to eq('Date')
    end
    it 'can take take a datetime and convert it to date' do
      date_datetime = 1.year.ago.to_datetime
      expected_date = date_datetime.to_date
      result_date   = time_calc_obj.convert_to_date(date_datetime)
      expect(result_date).to eq(expected_date)
      expect(result_date.class.name).to eq('Date')
    end
  end

  describe '#date_diff_in_days' do
    context 'in comparison to internal ruby calculations' do
      it 'tests ruby\'s internal calculation with leap years' do
        historical_date = 22.year.ago.to_date
        today_date      = Date.today
        date_diff       = (today_date - historical_date).to_i
        # 1996, 2000, 2004, 2008, 2012, 2016
        expect(date_diff).to eq((365 * 22) + 5)
      end
      it 'accurately calculates the diff from today' do
        historical_date = 5.year.ago.to_date
        today_date      = Date.today
        func_date_dif   = time_calc_obj.date_diff_in_days(historical_date,
                                                          today_date)
        ruby_date_diff  = (today_date - historical_date).to_i
        expect(func_date_dif).to eq(ruby_date_diff)
      end
    end
    context 'with only one input date' do
      it 'defaults date 2 to Date.today' do
        input_date = in_pst(5.years.ago)
        age_days = time_calc_obj.date_diff_in_days(input_date)
        expect(age_days).to be(5 * 365 + 1)
      end
      it 'can accept a string date' do
        string_date = 1.years.ago.to_s
        age_days = time_calc_obj.date_diff_in_days(string_date)
        expect(age_days).to be(365)
      end
    end

    context 'with multiple dates' do
      it 'returns the difference between the two dates in days' do
        input_date  = in_pst(5.years.ago).to_date
        input_date2 = 4.years.ago.to_date
        age_days    = time_calc_obj.date_diff_in_days(input_date, input_date2)
        expect(age_days).to be(365)
      end
      it 'can accept a string date' do
        string_date  = in_pst(5.years.ago).to_s
        string_date2 = 4.years.ago.to_s
        age_days = time_calc_obj.date_diff_in_days(string_date, string_date2)
        expect(age_days).to be(365)
      end
      it 'can accept date_time object' do
        string_date  = in_pst(5.years.ago).to_datetime
        string_date2 = 4.years.ago.to_datetime
        age_days = time_calc_obj.date_diff_in_days(string_date, string_date2)
        expect(age_days).to be(365)
      end
      it 'can accept time object' do
        string_date  = in_pst(5.years.ago)
        string_date2 = 4.years.ago.to_time
        age_days = time_calc_obj.date_diff_in_days(string_date, string_date2)
        expect(age_days).to be(365)
      end
    end
  end

  describe '#date_diff_in_years' do
    context 'with only one input date' do
      it 'defaults date 2 to Date.today' do
        input_date = in_pst(5.years.ago)
        age_in_years = time_calc_obj.date_diff_in_years(input_date)
        expect(age_in_years).to be(5)
      end
      it 'can accept a string date' do
        string_date = 1.years.ago.to_s
        age_in_years = time_calc_obj.date_diff_in_years(string_date)
        expect(age_in_years).to be(1)
      end
    end

    context 'with multiple dates' do
      it 'returns the difference between the two dates in years' do
        input_date   = in_pst(5.years.ago).to_date
        input_date2  = 4.years.ago.to_date
        age_in_years = time_calc_obj.date_diff_in_years(input_date, input_date2)
        expect(age_in_years).to be(1)
      end
      it 'can accept a string date' do
        str_date  = in_pst(5.years.ago).to_s
        str_date2 = 4.years.ago.to_s
        age_in_years = time_calc_obj.date_diff_in_years(str_date, str_date2)
        expect(age_in_years).to be(1)
      end
      it 'can accept date_time object' do
        str_date  = in_pst(5.years.ago).to_datetime
        str_date2 = 4.years.ago.to_datetime
        age_in_years = time_calc_obj.date_diff_in_years(str_date, str_date2)
        expect(age_in_years).to be(1)
      end
      it 'can accept time object' do
        str_date  = in_pst(5.years.ago)
        str_date2 = 4.years.ago.to_time
        age_in_years = time_calc_obj.date_diff_in_years(str_date, str_date2)
        expect(age_in_years).to be(1)
      end
    end
  end

  describe '#date_diff_in_months' do
    context 'with only one input date' do
      it 'defaults date 2 to Date.today' do
        input_date = in_pst(2.months.ago.to_date)
        age_in_months = time_calc_obj.date_diff_in_months(input_date)
        expect(age_in_months).to be(2)
      end
      it 'can accept a string date' do
        string_date = 1.month.ago.to_s
        diff_in_months = time_calc_obj.date_diff_in_months(string_date)
        expect(diff_in_months).to be(1)
      end
      it 'will return more than 12 months' do
        input_date = 2.years.ago.to_date
        diff_in_months = time_calc_obj.date_diff_in_months(input_date)
        expect(diff_in_months).to be(24)
      end
    end

    context 'with multiple dates' do
      it 'returns the difference between the two dates in months' do
        input_date     = 5.years.ago.to_date
        input_date2    = 4.years.ago.to_date
        diff_in_months = time_calc_obj.date_diff_in_months(input_date,
                                                           input_date2)
        expect(diff_in_months).to be(12)
      end
      it 'can accept a string date' do
        string_date  = 5.months.ago.to_s
        string_date2 = 4.months.ago.to_s
        diff_in_months = time_calc_obj.date_diff_in_months(string_date,
                                                           string_date2)
        expect(diff_in_months).to be(1)
      end
      it 'can accept date_time object' do
        string_date  = 5.years.ago.to_datetime
        string_date2 = 4.years.ago.to_datetime
        diff_in_months = time_calc_obj.date_diff_in_months(string_date,
                                                           string_date2)
        expect(diff_in_months).to be(12)
      end
      it 'can accept time object' do
        time_object  = 6.months.ago.to_time
        time_object2 = 4.months.ago.to_time
        diff_in_months = time_calc_obj.date_diff_in_months(time_object,
                                                           time_object2)
        expect(diff_in_months).to be(2)
      end
      it 'will return more than 12 months with two dates' do
        date1 = 5.years.ago.to_date
        date2 = 2.years.ago.to_date
        diff_in_months = time_calc_obj.date_diff_in_months(date1, date2)
        expect(diff_in_months).to be(36)
      end
      it 'will return 0 months with less than 1 month' do
        date1 = 1.month.ago.to_date
        date2 = 2.weeks.ago.to_date
        diff_in_months = time_calc_obj.date_diff_in_months(date1, date2)
        expect(diff_in_months).to be(0)
      end
      it 'will return 0 months with 29 days' do
        date1 = 1.month.ago.to_date
        date2 = 1.day.ago.to_date
        diff_in_months = time_calc_obj.date_diff_in_months(date1, date2)
        expect(diff_in_months).to be(0)
      end
      it 'will return the months between two dates' do
        date1 = 3.months.ago.to_date
        date2 = 2.weeks.ago.to_date
        diff_in_months = time_calc_obj.date_diff_in_months(date1, date2)
        expect(diff_in_months).to be(2)
      end
      it 'will be exact to the date with 2 months and 30 days' do
        date1 = 5.months.ago.to_date
        date2 = 2.months.ago.to_date.ago(1.day).to_date
        diff_in_months = time_calc_obj.date_diff_in_months(date1, date2)
        expect(diff_in_months).to be(2)
      end
      it 'will be exact to the date with 3 months and 1 days' do
        date1 = 5.months.ago.to_date
        date2 = 2.months.ago.to_date.since(1.day).to_date
        diff_in_months = time_calc_obj.date_diff_in_months(date1, date2)
        expect(diff_in_months).to be(3)
      end
    end
  end

  describe '#date_diff_in_weeks' do
    context 'with only one input date' do
      it 'defaults date 2 to Date.today' do
        input_date = in_pst(1.month.ago)
        diff_in_weeks = time_calc_obj.date_diff_in_weeks(input_date)
        expect(diff_in_weeks).to be(4)
      end
      it 'can accept a string date' do
        string_date = 1.month.ago.to_s
        diff_in_weeks = time_calc_obj.date_diff_in_weeks(string_date)
        expect(diff_in_weeks).to be(4)
      end
      it 'will return more than 4 weeks' do
        input_date = 2.months.ago.to_date
        diff_in_weeks = time_calc_obj.date_diff_in_weeks(input_date)
        expect(diff_in_weeks).to be(8)
      end
    end

    context 'with multiple dates' do
      it 'returns the difference between the two dates in weeks' do
        input_date    = 4.months.ago.to_date
        input_date2   = 3.months.ago.to_date
        diff_in_weeks = time_calc_obj.date_diff_in_weeks(input_date, input_date2)
        expect(diff_in_weeks).to be(4)
      end
      it 'can accept a string date' do
        string_date   = 5.years.ago.to_s
        string_date2  = 4.years.ago.to_s
        diff_in_weeks = time_calc_obj.date_diff_in_weeks(string_date, string_date2)
        expect(diff_in_weeks).to be(52)
      end
      it 'can accept date_time object' do
        string_date   = 5.months.ago.to_datetime
        string_date2  = 4.months.ago.to_datetime
        diff_in_weeks = time_calc_obj.date_diff_in_weeks(string_date, string_date2)
        expect(diff_in_weeks).to be(4)
      end
      it 'can accept time object' do
        time_object   = 5.months.ago.to_time
        time_object2  = 4.months.ago.to_time
        diff_in_weeks = time_calc_obj.date_diff_in_weeks(time_object, time_object2)
        expect(diff_in_weeks).to be(4)
      end
      it 'will return more than 4 weeks with two dates' do
        date1 = 4.years.ago.to_date
        date2 = 2.years.ago.to_date
        diff_in_weeks = time_calc_obj.date_diff_in_weeks(date1, date2)
        expect(diff_in_weeks).to be(104)
      end
    end
  end

  describe '#time_string_to_time_hash' do
    context 'with only one input time type (week, month, year)' do
      string_times = [
        ['6 weeks', { weeks: 6 }],
        ['10 weeks', { weeks: 10 }],
        ['4 weeks', { weeks: 4 }],
        ['8 weeks', { weeks: 8 }],
        ['13 weeks', { weeks: 13 }],
        ['14 weeks', { weeks: 14 }],
        ['16 weeks', { weeks: 16 }],
        ['2 months', { months: 2 }],
        ['4 months', { months: 4 }],
        ['6 months', { months: 6 }],
        ['19 months', { months: 19 }],
        ['12 months', { months: 12 }],
        ['7 months', { months: 7 }],
        ['12 months', { months: 12 }],
        ['18 years', { years: 18 }],
        ['7 years', { years: 7 }],
        ['5 years', { years: 5 }],
        ['4 years', { years: 4 }],
        ['3 years', { years: 3 }]
      ]
      string_times.each do |string_time_data|
        input_string = string_time_data[0]
        output_hash  = string_time_data[1]
        it "takes input string #{input_string} and returns #{output_hash}" do
          expect(
            time_calc_obj.time_string_to_time_hash(input_string)
          ).to eq(output_hash)
        end
      end
    end

    context 'with many input time type (week, month, year)' do
      string_times = [
        ['4 weeks + 4 days', { weeks: 4, days: 4 }],
        ['6 weeks - 4 days', { weeks: 6, days: -4 }],
        ['8 weeks - 4 days', { weeks: 8, days: -4 }],
        ['10 weeks - 4 days', { weeks: 10, days: -4 }],
        ['14 weeks - 4 days', { weeks: 14, days: -4 }],
        ['3 months + 4 weeks', { weeks: 4, months: 3 }],
        ['5 months + 4 weeks', { weeks: 4, months: 5 }],
        ['6 months - 4 days', { days: -4, months: 6 }],
        ['7 months - 4 days', { days: -4, months: 7 }],
        ['7 months + 4 weeks', { weeks: 4, months: 7 }],
        ['10 months + 4 weeks', { weeks: 4, months: 10 }],
        ['12 months - 4 days', { days: -4, months: 12 }],
        ['15 months + 4 weeks', { weeks: 4, months: 15 }],
        ['15 months - 4 days', { days: -4, months: 15 }],
        ['16 months + 4 weeks', { weeks: 4, months: 16 }],
        ['19 months + 4 weeks', { weeks: 4, months: 19 }],
        ['4 years - 4 days', { days: -4, years: 4 }],
        ['6 years + 4 weeks', { weeks: 4, years: 6 }],
        ['7 years + 4 weeks', { weeks: 4, years: 7 }]
      ]
      string_times.each do |string_time_data|
        input_string = string_time_data[0]
        output_hash  = string_time_data[1]
        it "takes input string #{input_string} and returns #{output_hash}" do
          expect(
            time_calc_obj.time_string_to_time_hash(input_string)
          ).to eq(output_hash)
        end
      end
    end
  end

  describe '#detailed_date_diff' do
    context 'with only one input date' do
      it 'defaults date 2 to Date.today' do
        input_date = in_pst(1.month.ago)
        detailed_date_diff = time_calc_obj.detailed_date_diff(input_date)
        expect(detailed_date_diff).to eq('0y, 1m, 0w')
      end
      it 'can accept a string date' do
        string_date = 1.month.ago.to_s
        detailed_date_diff = time_calc_obj.detailed_date_diff(string_date)
        expect(detailed_date_diff).to eq('0y, 1m, 0w')
      end
      it 'can accept date_time object' do
        string_date = 1.months.ago.to_datetime
        detailed_date_diff = time_calc_obj.detailed_date_diff(string_date)
        expect(detailed_date_diff).to eq('0y, 1m, 0w')
      end
      it 'can accept time object' do
        time_date = 1.months.ago.to_time
        detailed_date_diff = time_calc_obj.detailed_date_diff(time_date)
        expect(detailed_date_diff).to eq('0y, 1m, 0w')
      end
    end

    context 'with multiple dates' do
      context 'with exact differences' do
        it 'will return only weeks for under 1 month' do
          input_date  = 1.months.ago.to_date
          input_date2 = 2.weeks.ago.to_date
          detailed_date_diff = time_calc_obj.detailed_date_diff(input_date,
                                                                input_date2)
          expect(detailed_date_diff).to eq('0y, 0m, 2w')
        end
        it 'will return only months for exact months' do
          input_date  = 3.months.ago.to_date
          input_date2 = 1.month.ago.to_date
          detailed_date_diff = time_calc_obj.detailed_date_diff(input_date,
                                                                input_date2)
          expect(detailed_date_diff).to eq('0y, 2m, 0w')
        end
        it 'will return only years for exact years' do
          input_date  = 5.years.ago.to_date
          input_date2 = 2.years.ago.to_date
          detailed_date_diff = time_calc_obj.detailed_date_diff(input_date,
                                                                input_date2)
          expect(detailed_date_diff).to eq('3y, 0m, 0w')
        end
      end
      context 'with multiple differences' do
        it 'will return years, months and weeks multi year' do
          input_date  = 5.years.ago.to_date.ago(1.month).ago(2.weeks)
          input_date2 = 1.year.ago.to_date
          detailed_date_diff = time_calc_obj.detailed_date_diff(input_date,
                                                                input_date2)
          expect(detailed_date_diff).to eq('4y, 1m, 2w')
        end
        it 'will return months and weeks for multi month' do
          input_date  = 5.months.ago.to_date.ago(3.weeks)
          input_date2 = 1.month.ago.to_date
          detailed_date_diff = time_calc_obj.detailed_date_diff(input_date,
                                                                input_date2)
          expect(detailed_date_diff).to eq('0y, 4m, 3w')
        end
        it 'will return years and weeks for exact year/week' do
          input_date  = 5.years.ago.to_date.ago(1.week)
          input_date2 = 3.year.ago.to_date
          detailed_date_diff = time_calc_obj.detailed_date_diff(input_date,
                                                                input_date2)
          expect(detailed_date_diff).to eq('2y, 0m, 1w')
        end
        it 'will return years and months for exact year/months' do
          input_date  = 5.years.ago.to_date.ago(5.month)
          input_date2 = 1.year.ago.to_date
          detailed_date_diff = time_calc_obj.detailed_date_diff(input_date,
                                                                input_date2)
          expect(detailed_date_diff).to eq('4y, 5m, 0w')
        end
      end
    end
  end

  describe '#date_minus_time_period' do
    before(:each) do
      new_time = Time.local(2015, 7, 15, 10, 0, 0)
      Timecop.freeze(new_time)
    end
    after(:each) do
      Timecop.return
    end
    it 'takes an input date and a collection of different time units' do
      years, months, weeks = 1, 2, 2
      start_date    = Date.today
      expected_date = Date.new(2014, 5, 1)
      expect(
        time_calc_obj.date_minus_time_period(start_date,
                                             years: years,
                                             months: months,
                                             weeks: weeks)
      ).to eq(expected_date)
    end
    it 'accounts for the leap year' do
      new_time = Time.local(2016, 3, 3, 10, 0, 0)
      Timecop.freeze(new_time) do
        years, months, weeks = 1, 0, 2
        start_date    = Date.today
        expected_date = Date.new(2015, 2, 17)
        expect(
          time_calc_obj.date_minus_time_period(start_date,
                                               years: years,
                                               months: months,
                                               weeks: weeks)
        ).to eq(expected_date)
      end
    end
    it 'calculates months differently than just 4 weeks' do
      months, weeks = 2, 8
      start_date    = Date.today
      expected_date1 = Date.new(2015, 5, 15)
      expected_date2 = Date.new(2015, 5, 20)
      expect(time_calc_obj.date_minus_time_period(start_date, months: months)).to eq(expected_date1)
      expect(time_calc_obj.date_minus_time_period(start_date, weeks: weeks)).to eq(expected_date2)
    end
  end
end
