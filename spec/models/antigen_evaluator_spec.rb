require 'rails_helper'

RSpec.describe AntigenEvaluator, type: :model do
  before(:all) { FactoryGirl.create(:seed_antigen_xml) }
  after(:all) { DatabaseCleaner.clean_with(:truncation) }

  let(:test_antigen) { Antigen.find_by(target_disease: 'polio') }
  let(:test_patient) { FactoryGirl.create(:patient) }
  describe "validations" do

    it 'requires a patient object' do
      expect{ AntigenEvaluator.new(antigen: test_antigen) }.to raise_exception(ArgumentError)
    end
    it 'requires an antigen object' do
      expect{ AntigenEvaluator.new(patient: test_patient) }.to raise_exception(ArgumentError)
    end
  end
  describe "relationships" do
    let(:antigen_evaluator) { AntigenEvaluator.new(patient: test_patient, antigen: test_antigen) }
    it 'creates all patient series for the antigen' do
      expect(antigen_evaluator.patient_serieses.length).to eq(3)
      expect(antigen_evaluator.patient_serieses.first.class.name).to eq('PatientSeries')
    end
    it 'orders all patient series by preference number' do
      expect(antigen_evaluator.patient_serieses.map(&:preference_number)).to eq([1, 2, 3])
    end
  end

end
