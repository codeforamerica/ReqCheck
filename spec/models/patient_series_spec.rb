require 'rails_helper'

RSpec.describe PatientSeries, type: :model do
  let(:test_patient) { FactoryGirl.create(:patient) }
  let(:antigen_series) { FactoryGirl.create(:antigen_series) }
  
  describe 'validations' do
    it 'takes a patient and antigen_series as parameters' do
      expect(
        PatientSeries.new(antigen_series: antigen_series,
                       patient: test_patient).class.name
      ).to eq('PatientSeries')
    end

    it 'requires a patient object' do
      expect{PatientSeries.new(antigen_series: antigen_series)}.to raise_exception
    end
    it 'requires an antigen_series' do
      expect{PatientSeries.new(patient: test_patient)}.to raise_exception
    end
  end

  describe '#create_target_doses' do
    before(:all) { FactoryGirl.create(:seed_antigen_xml) }
    after(:all) { DatabaseCleaner.clean_with(:truncation) }

    let(:antigen_series) { Antigen.find_by(target_disease: 'polio') }

    it 'maps through the antigen_series_doses and creates a target_dose for each one' do
      patient_series = PatientSeries.new(antigen_series: antigen_series, patient: test_patient)
      antigen_series_length = antigen_series.doses.length
      patient_series.create_target_doses
      expect(patient_series.target_doses.length).to eq(antigen_series_length)
    end
    it 'creates target_doses' do
      patient_series = PatientSeries.new(antigen_series: antigen_series, patient: test_patient)
      patient_series.create_target_doses
      expect(patient_series.target_doses.first.class.name).to eq('TargetDose')
    end
    it 'removes old objects' do
      patient_series = PatientSeries.new(antigen_series: antigen_series, patient: test_patient)
      patient_series.create_target_doses
      first_target_dose = patient_series.target_doses.first
      patient_series.create_target_doses
      expect(patient_series.target_doses.first).not_to eq(first_target_dose)
    end
  end
end
