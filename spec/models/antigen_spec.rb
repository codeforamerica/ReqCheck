require 'rails_helper'

RSpec.describe Antigen, type: :model do
  describe '#create' do
    it 'requires a name' do
      expect{ Antigen.create }.to raise_exception
      expect(Antigen.create(name: 'Test').class.name).to eq('Antigen')
    end
  end

  describe 'its relationship with vaccines' do
    it 'has multiple vaccines' do
      antigen = Antigen.create(name: 'Polio')
      vaccine = FactoryGirl.create(:vaccine)
      antigen.vaccines << vaccine
    end
  end
end
