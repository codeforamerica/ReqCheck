require 'rails_helper'

RSpec.describe AntigenSeries, type: :model do
  describe "validations" do
      it { should validate_presence_of(:name) }
      it { should validate_presence_of(:target_disease) }
      it { should validate_presence_of(:vaccine_group) }
  end
  describe 'relationships' do
    it 'has many series_doses' do
      antigen_series = FactoryGirl.create(:antigen_series)
      antigen_series_dose = FactoryGirl.create(:antigen_series_dose)
      antigen_series.doses << antigen_series_dose
    end
  end
end
