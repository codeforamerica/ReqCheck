require 'rails_helper'

RSpec.describe TargetDose, type: :model do
  before(:all) do
    FactoryGirl.create(:seed_antigen_xml)
  end
  after(:all) do
    DatabaseCleaner.clean_with(:truncation)
  end

  describe 'validations' do
    let(:test_patient) { FactoryGirl.create(:patient) }
    let(:antigen_series_dose) { FactoryGirl.create(:antigen_series_dose) }
    it 'takes a patient and antigen_series_dose as parameters' do
      expect(
        TargetDose.new(antigen_series_dose: antigen_series_dose,
                       patient: test_patient).class.name
      ).to eq('TargetDose')
    end

    it 'requires a patient object' do
      expect{TargetDose.new(antigen_series_dose: antigen_series_dose)}.to raise_exception
    end
    it 'requires an antigen_series_dose' do
      expect{TargetDose.new(patient: test_patient)}.to raise_exception
    end
  end
  describe 'relationships' do
    let(:test_patient) { FactoryGirl.create(:patient) }
    
  end
end
