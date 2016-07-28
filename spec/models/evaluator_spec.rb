require 'rails_helper'

RSpec.describe Evaluator, type: :model do
  before(:all) do
    FactoryGirl.create(:seed_antigen_xml)
  end
  after(:all) do
    DatabaseCleaner.clean_with(:truncation)
  end

  describe 'validations' do
    it 'requires a patient object' do
      expect{Evaluator.new}.to raise_exception
    end
  end
  describe 'relationships' do
    let(:test_patient) { FactoryGirl.create(:patient) }
    it 'has access to all the antigens' do
      evaluator = Evaluator.new(patient: test_patient)
      expect(evaluator.antigens.length).to eq(17)
    end
    it 'has access to all the antigens' do
      evaluator = Evaluator.new(patient: test_patient)
      expect(evaluator.antigens.length).to eq(17)
    end
  end

  describe '#create_all_patient_series' do
    let(:test_patient) { FactoryGirl.create(:patient) }
    let(:evaluator) { Evaluator.new(patient: test_patient) }

    

  end




  describe '#build_patient_series' do
    context 'with a child aged < 1 years' do
      let(:test_patient_baby) { FactoryGirl.create(:patient, dob: 10.months.ago) }

    end
    context 'with a child aged ~= 5 years' do
      let(:test_patient_child) { FactoryGirl.create(:patient, dob: 58.months.ago) }

    end
    context 'with a child aged ~= 12 years' do
      let(:test_patient_child) { FactoryGirl.create(:patient, dob: 12.years.ago) }

    end
    context 'with a child aged ~= 18 years' do
      let(:test_patient_child) { FactoryGirl.create(:patient, dob: 12.years.ago) }

    end

  end
end
