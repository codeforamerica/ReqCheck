require 'rails_helper'

RSpec.describe AntigenSeries, type: :model do
  describe "validations" do
    subject { FactoryGirl.create(:antigen_series) }
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:target_disease) }
    it { should validate_presence_of(:min_start_age).strict }
    it { should validate_presence_of(:max_start_age).strict }
    it { should validate_numericality_of(:preference_number).strict }

  end
  describe 'relationships' do
    it 'has many doses' do
      antigen_series = FactoryGirl.create(:antigen_series)
      antigen_series_dose = FactoryGirl.create(:antigen_series_dose)
      antigen_series.doses << antigen_series_dose
      expect(antigen_series.doses).to eq([antigen_series_dose])
    end
    it 'has one antigen' do
      antigen_series = FactoryGirl.create(:antigen_series)
      antigen = FactoryGirl.create(:antigen)
      antigen.series << antigen_series
      expect(antigen_series.antigen).to eq(antigen)
    end
  end
end
