require 'rails_helper'

RSpec.describe Antigen, type: :model do
  describe '#create' do
    it 'requires a name' do
      expect{ Antigen.create }.to raise_exception
      expect(Antigen.create(name: 'Test').class.name).to eq('Antigen')
    end
    it 'has a json field named xml_hash' do
      antigen = Antigen.create(name: 'Test')
      xml_hash = {"hello": "world"}.stringify_keys
      antigen.xml_hash = xml_hash
      antigen.save
      expect(Antigen.first.xml_hash).to eq(xml_hash)
    end
  end

  describe 'relationships' do
    it 'has many series' do
      antigen = FactoryGirl.create(:antigen)
      antigen_series = FactoryGirl.create(:antigen_series)
      antigen.series << antigen_series
      expect(antigen.series).to eq([antigen_series])
    end
    it 'has multiple vaccines' do
      antigen = Antigen.create(name: 'Polio')
      vaccine = FactoryGirl.create(:vaccine)
      antigen.vaccines << vaccine
      expect(antigen.vaccines).to eq([vaccine])
    end
  end
end
