require 'rails_helper'

RSpec.describe AntigenSeriesDoseVaccine, type: :model do
  describe "validations" do
    it { should validate_presence_of(:vaccine_type) }
    it { should validate_presence_of(:cvx_code) }
    it { should validate_presence_of(:preferable) }
  end
  describe 'relationships' do
    it 'has one series dose' do
      antigen_series = FactoryGirl.create(:antigen_series)
      antigen_series_dose = FactoryGirl.create(:antigen_series_dose)
      antigen_series.doses << antigen_series_dose
    end
  end
end
