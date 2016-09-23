require 'rails_helper'

RSpec.describe Interval, type: :model do
  describe "validations" do
    it { should validate_presence_of(:interval_type) }
  end
  describe 'relationships' do
    it 'belongs to a series_dose' do
      series_dose = FactoryGirl.create(:antigen_series_dose)
      interval    = Interval.create(
        interval_type: 'Previous',
        interval_absolute_min: '4 weeks - 4 days',
        interval_min: '4 weeks',
        interval_earliest_recommended: '8 weeks',
        interval_latest_recommended: '13 weeks',
        antigen_series_dose: series_dose
      )
      series_dose.reload
      expect(series_dose.intervals.first).to eq(interval)
      expect(interval.antigen_series_dose).to eq(series_dose)
    end
  end
end
