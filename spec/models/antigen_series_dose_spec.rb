require 'rails_helper'

RSpec.describe AntigenSeriesDose, type: :model do
  describe "validations" do
    it { should validate_presence_of(:dose_number) }
  end
  describe 'relationships' do
    it 'has many dose_vaccines' do
      antigen_series_dose = FactoryGirl.create(:antigen_series_dose)
      asd_vaccine = FactoryGirl.create(:antigen_series_dose_vaccine)
      antigen_series_dose.dose_vaccines << asd_vaccine
      expect(antigen_series_dose.dose_vaccines).to include(asd_vaccine)
    end
    it 'has many preferable_vaccines' do
      antigen_series_dose = FactoryGirl.create(:antigen_series_dose)
      asd_vaccine = FactoryGirl.create(:antigen_series_dose_vaccine)
      antigen_series_dose.dose_vaccines << asd_vaccine
      expect(antigen_series_dose.preferable_vaccines).to include(asd_vaccine)
      expect(antigen_series_dose.allowable_vaccines).not_to include(asd_vaccine)
    end
    it 'has many allowable_vaccines' do
      antigen_series_dose = FactoryGirl.create(:antigen_series_dose)
      asd_vaccine = FactoryGirl.create(:antigen_series_dose_vaccine, preferable: false)
      antigen_series_dose.dose_vaccines << asd_vaccine
      expect(antigen_series_dose.allowable_vaccines).to include(asd_vaccine)
      expect(antigen_series_dose.preferable_vaccines).not_to include(asd_vaccine)
    end
    it 'can have one conditional_skip' do
      antigen_series_dose = FactoryGirl.create(:antigen_series_dose)
      conditional_skip = FactoryGirl.create(:conditional_skip)
      antigen_series_dose.update(conditional_skip: conditional_skip)
      expect(antigen_series_dose.conditional_skip).to eq(conditional_skip)
    end
    it 'has one antigen_series' do
      antigen_series_dose = FactoryGirl.create(:antigen_series_dose)
      antigen_series = FactoryGirl.create(:antigen_series)
      antigen_series.doses << antigen_series_dose
      expect(antigen_series_dose.antigen_series).to eq(antigen_series)
    end
  end
end
