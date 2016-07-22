require 'rails_helper'

RSpec.describe AntigenSeriesDoseVaccine, type: :model do
  describe "validations" do
    it { should validate_presence_of(:vaccine_type) }
    it { should validate_presence_of(:cvx_code) }
  end
  describe 'relationships' do
    it 'has many antigen_series_doses' do
      asd_vaccine = FactoryGirl.create(:antigen_series_dose_vaccine)
      as_dose = FactoryGirl.create(:antigen_series_dose)
      asd_vaccine.antigen_series_doses << as_dose
      expect(asd_vaccine.antigen_series_doses).to eq([as_dose])
    end
    it 'has many antigens' do
      asd_vaccine = FactoryGirl.create(:antigen_series_dose_vaccine)
      as_dose     = FactoryGirl.create(:antigen_series_dose, dose_vaccines: [asd_vaccine])
      as_series   = FactoryGirl.create(:antigen_series, doses: [as_dose])
      FactoryGirl.create(:antigen, series: [as_series])
      expect(asd_vaccine.antigens.first.class.name).to eq('Antigen')
      expect(asd_vaccine.antigens.length).to eq(1)
    end
  end
end
