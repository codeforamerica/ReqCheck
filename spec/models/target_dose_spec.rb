require 'rails_helper'

RSpec.describe TargetDose, type: :model do
  # describe 'validations' do
  #   let(:test_patient) { FactoryGirl.create(:patient) }
  #   let(:antigen_series_dose) { FactoryGirl.create(:antigen_series_dose) }
  #   it 'takes a patient and antigen_series_dose as parameters' do
  #     expect(
  #       TargetDose.new(antigen_series_dose: antigen_series_dose,
  #                      patient: test_patient).class.name
  #     ).to eq('TargetDose')
  #   end

  #   it 'requires a patient object' do
  #     expect{TargetDose.new(antigen_series_dose: antigen_series_dose)}.to raise_exception
  #   end
  #   it 'requires an antigen_series_dose' do
  #     expect{TargetDose.new(patient: test_patient)}.to raise_exception
  #   end
  # end
  
  # describe '#required_for_patient' do
  #   let(:test_patient) { FactoryGirl.create(:patient_profile, dob: 2.years.ago).patient }
  #   let(:antigen_series_dose) { FactoryGirl.create(:antigen_series_dose) }

  #   it 'checks if the target_dose is required for the patient and returns boolean' do
  #     target_dose = TargetDose.new(patient: test_patient, antigen_series_dose: antigen_series_dose)
  #     expect(target_dose.required_for_patient).to eq(true)
  #   end
  #   it 'returns false if the antigen_series_dose dose not satisfy the ' do
  #     target_dose = TargetDose.new(patient: test_patient, antigen_series_dose: antigen_series_dose)
  #     expect(target_dose.required_for_patient).to eq(true)
  #   end
  # end

end
