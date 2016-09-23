require 'rails_helper'

RSpec.describe Evaluator, type: :model do
  before(:all) do
    FactoryGirl.create(:seed_full_antigen_xml)
  end
  after(:all) do
    DatabaseCleaner.clean_with(:truncation)
  end
  let(:test_patient) do
    patient = FactoryGirl.create(:patient_with_profile)
    FactoryGirl.create(:vaccine_dose, vaccine_code: 'POL', patient_profile: patient.patient_profile)
    FactoryGirl.create(:vaccine_dose, vaccine_code: 'POL', patient_profile: patient.patient_profile)
    patient
  end
  let(:test_aars) do
    AntigenAdministeredRecord.create_records_from_vaccine_doses(test_patient.vaccine_doses)
  end

  let(:evaluator) { Evaluator.new(patient: test_patient) }

  describe 'validations' do
    it 'requires a patient object' do
      expect{Evaluator.new}.to raise_exception(ArgumentError)
    end
  end

  describe 'relationships' do
    it 'creates a patients antigen_administered_records' do
      expect(evaluator.antigen_administered_records.length).to eq(2)
      expect(evaluator.antigen_administered_records.first.class.name).to eq('AntigenAdministeredRecord')
    end
  end

  describe '#get_antigens' do
    it 'pulls all antigens from the database' do
      expect(evaluator.get_antigens.length).to eq(17)
    end
    it 'pulls only unique antigens from the database' do
      expect(evaluator.get_antigens.length).to eq(17)
      FactoryGirl.create(:antigen, target_disease: 'polio')
      expect(evaluator.get_antigens.length).to eq(17)
    end
  end

  describe '#create_all_antigen_evaluators' do
    it 'creates all patient series for each antigen' do
      antigens = Antigen.all
      evaluator.create_all_antigen_evaluators(test_patient, antigens, test_aars)
      expect(evaluator.antigen_evaluators.length).to eq(17)
      expect(evaluator.antigen_evaluators.first.class.name).to eq('AntigenEvaluator')
      expect(evaluator.antigen_evaluators.first.patient_serieses.first.class.name).to eq('PatientSeries')
    end
  end


  describe '#build_patient_series' do
    context 'with a child aged < 1 years' do
      let(:test_patient_baby) { FactoryGirl.create(:patient_with_profile, dob: 10.months.ago) }

    end
    context 'with a child aged ~= 5 years' do
      let(:test_patient_child) { FactoryGirl.create(:patient_with_profile, dob: 58.months.ago) }

    end
    context 'with a child aged ~= 12 years' do
      let(:test_patient_child) { FactoryGirl.create(:patient_with_profile, dob: 12.years.ago) }

    end
    context 'with a child aged ~= 18 years' do
      let(:test_patient_child) { FactoryGirl.create(:patient_with_profile, dob: 12.years.ago) }

    end

  end
end
