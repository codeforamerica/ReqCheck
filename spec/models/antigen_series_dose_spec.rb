require 'rails_helper'

RSpec.describe AntigenSeriesDose, type: :model do
  describe "validations" do
    it { should validate_presence_of(:dose_number) }
    it { should validate_presence_of(:interval_type) }
  end
  describe 'relationships' do
    it 'has many preferable_vaccines' do
      antigen_series = FactoryGirl.create(:antigen_series)
      antigen_series_dose = FactoryGirl.create(:antigen_series_dose)
      antigen_series.doses << antigen_series_dose
    end
    it 'has many allowable_vaccines' do
      antigen_series = FactoryGirl.create(:antigen_series)
      antigen_series_dose = FactoryGirl.create(:antigen_series_dose)
      antigen_series.doses << antigen_series_dose
    end
  end
end
