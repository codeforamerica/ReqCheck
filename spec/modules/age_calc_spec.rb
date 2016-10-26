require 'rails_helper'
require 'time_calc'

RSpec.describe AgeCalc do
  let(:test_class) do
    class TestClass
      include AgeCalc
    end
    TestClass.new
  end

  let(:earlier_date) { 4.months.ago.to_date }
  let(:later_date) { 3.months.ago.to_date }

  describe '#validate_date_equal_or_after' do
    it 'returns true if the dates are exact' do
      expect(
        test_class.validate_date_equal_or_after(earlier_date, earlier_date)
      ).to eq(true)
    end

    it 'returns true if the evaluated_date is after the base_date' do
      expect(
        test_class.validate_date_equal_or_after(earlier_date, later_date)
      ).to eq(true)
    end

    it 'returns false if the evaluated_date is before the base_date' do
      expect(
        test_class.validate_date_equal_or_after(later_date, earlier_date)
      ).to eq(false)
    end
  end

  describe '#validate_date_equal_or_before' do
    it 'returns true if the dates are exact' do
      expect(
        test_class.validate_date_equal_or_before(later_date, later_date)
      ).to eq(true)
    end

    it 'returns true if the evaluated_date is before the base_date' do
      expect(
        test_class.validate_date_equal_or_before(later_date, earlier_date)
      ).to eq(true)
    end

    it 'returns false if the evaluated_date is after the base_date' do
      expect(
        test_class.validate_date_equal_or_before(earlier_date, later_date)
      ).to eq(false)
    end
  end
  describe '#create_calculated_date' do
    it 'takes a time string and a start date and returns the date diff' do
      time_string   = '6 weeks'
      input_date    = 10.weeks.ago
      expected_date = 4.weeks.ago.to_date
      expect(test_class.create_calculated_date(time_string, input_date))
        .to eq(expected_date)
    end
  end
end
