require 'rails_helper'
require 'time_calculations'

RSpec.describe TimeCalc do
  let(:extended_class) { Class.new { extend TimeCalc } }

  describe "#date_diff_in_days" do
    context "with only one input date" do
      it "defaults date 2 to Date.today" do
        input_date = 5.years.ago
        age_days = extended_class.date_diff_in_days(input_date)
        expect(age_days).to be(5 * 365)
      end
      it "takes can accept a string date" do
        string_date = 1.years.ago.to_s
        age_days = extended_class.date_diff_in_days(string_date)
        expect(age_days).to be(365)
      end
    end

    context "with multiple dates" do
      it "returns the difference between the two dates in days" do
        input_date  = 5.years.ago.to_date
        input_date2 = 4.years.ago.to_date
        age_days    = extended_class.date_diff_in_days(input_date, input_date2)
        expect(age_days).to be(365)
      end
      it "takes can accept a string date" do
        string_date  = 5.years.ago.to_s
        string_date2 = 4.years.ago.to_s
        age_days = extended_class.date_diff_in_days(string_date, string_date2)
        expect(age_days).to be(365)
      end
      it "can accept date_time object" do
        string_date  = 5.years.ago.to_datetime
        string_date2 = 4.years.ago.to_datetime
        age_days = extended_class.date_diff_in_days(string_date, string_date2)
        expect(age_days).to be(365)
      end
      it "can accept time object" do
        string_date  = 5.years.ago
        string_date2 = 4.years.ago
        age_days = extended_class.date_diff_in_days(string_date, string_date2)
        expect(age_days).to be(365)
      end
    end
  end

  describe "#validate_day_diff" do
    it "takes an day_diff and required_days and returns boolean" do
      day_diff = 100
      required_days = 80
      expect(extended_class.validate_day_diff(day_diff, required_days)).to be(true)
    end

    it "returns true when the day_diff is higher than required days" do
      day_diff = 100
      required_days = 80
      expect(extended_class.validate_day_diff(day_diff, required_days)).to be(true)
    end
    
    it "returns false when the day_diff is lower than required days" do
      day_diff = 60
      required_days = 80
      expect(extended_class.validate_day_diff(day_diff, required_days)).to be(false)
    end
  end



end
