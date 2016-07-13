require 'rails_helper'

RSpec.describe AntigenSeriesDoseVaccine, type: :model do
  describe "validations" do
    it { should validate_presence_of(:vaccine_type) }
    it { should validate_presence_of(:cvx_code) }
    it { should validate_presence_of(:preferable) }
  end
  describe 'relationships' do
    it 'has one antigen_series_dose' do
      asd_vaccine = FactoryGirl.create(:antigen_series_dose_vaccine)
      as_dose = FactoryGirl.create(:antigen_series_dose,
        antigen_series_dose_vaccines: [asd_vaccine]
      )
      expect(asd_vaccine.antigen_series_dose).to eq(as_dose)
    end
  end
end
