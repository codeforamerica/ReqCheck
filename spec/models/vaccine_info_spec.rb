require 'rails_helper'

RSpec.describe VaccineInfo, type: :model do
  describe '#create' do
    it 'requires a cvx code' do
      expect{ VaccineInfo.create }.to raise_exception
      expect(VaccineInfo.create(cvx_code: 100).class.name).to eq('VaccineInfo')
    end
  end

  describe 'its relationship with antigens' do
    it 'has multiple antigens' do
      vaccine_info = VaccineInfo.create(cvx_code: 100)
      antigen1 = FactoryGirl.create(:antigen)
      antigen2 = FactoryGirl.create(:antigen)
      vaccine_info.antigens << antigen1
      vaccine_info.antigens << antigen2
    end
  end
end
