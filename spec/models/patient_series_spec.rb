require 'rails_helper'

RSpec.describe PatientSeries, type: :model do
  before(:all) { FactoryGirl.create(:seed_antigen_xml) }
  after(:all) { DatabaseCleaner.clean_with(:truncation) }
  let(:test_patient) { FactoryGirl.create(:patient) }
  let(:antigen_series) { Antigen.find_by(target_disease: 'polio').series.first }
  
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

    it 'automatically calls #create_target_doses' do
      expect(
        PatientSeries.new(antigen_series: antigen_series, patient: test_patient).target_doses.length
      ).not_to eq(0)
    end
  end

  describe '#create_target_doses' do
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
    it 'orders them by dose number' do
      patient_series = PatientSeries.new(antigen_series: antigen_series, patient: test_patient)
      patient_series.create_target_doses

      first_target_dose  = patient_series.target_doses[0]
      expect(first_target_dose.dose_number).to eq(1)

      second_target_dose = patient_series.target_doses[1]
      expect(second_target_dose.dose_number).to eq(2)
    end
  end

  
  describe 'patient_series attributes from the antigen_series' do
    let(:test_patient_series) do
      PatientSeries.new(antigen_series: antigen_series, patient: test_patient)
    end
    
    dose_attributes = ['name', 'target_disease', 'vaccine_group', 'default_series', 'product_path',
                       'preference_number', 'min_start_age', 'max_start_age']

    dose_attributes.each do | dose_attribute |
      it "has the attribute #{dose_attribute}" do
        expect(test_patient_series.antigen_series).not_to eq(nil)
        expect(test_patient_series.send(dose_attribute)).to eq(antigen_series.send(dose_attribute))
      end
    end
  end

  describe '.create_antigen_patient_serieses' do
    let(:antigen) { Antigen.find_by(target_disease: 'polio') }

    it 'takes a patient and antigen and creates an array of patient_series objects' do
      patient_series = PatientSeries.create_antigen_patient_serieses(antigen: antigen,
                                                                     patient: test_patient)
      expect(patient_series.length).to eq(3)
      expect(patient_series.first.class.name).to eq('PatientSeries')
      expect(patient_series.length).to eq(antigen.series.length)
    end
    it 'returns the patient_serieses in the order of the preference_number' do
      patient_series = PatientSeries.create_antigen_patient_serieses(antigen: antigen,
                                                                     patient: test_patient)
      expect(patient_series.map(&:preference_number)).to eq([1, 2, 3])
    end
  end
end
