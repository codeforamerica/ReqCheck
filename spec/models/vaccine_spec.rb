require 'rails_helper'

RSpec.describe Vaccine, type: :model do
  describe '#create' do
    it 'requires a cvx code' do
      expect{ Vaccine.create }.to raise_exception
      expect(Vaccine.create(cvx_code: 100).class.name).to eq('Vaccine')
    end
  end

  describe 'its relationship with antigens' do
    it 'has multiple antigens' do
      vaccine = Vaccine.create(cvx_code: 100)
      antigen1 = FactoryGirl.create(:antigen)
      antigen2 = FactoryGirl.create(:antigen)
      vaccine.antigens << antigen1
      vaccine.antigens << antigen2
    end
  end
end
