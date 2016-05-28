require 'rails_helper'

RSpec.describe Patient, type: :model do
  describe "test the factory first" do
    it "has a patient profile automatically created" do
      patient = FactoryGirl.create(:patient)
      patient_profile = PatientProfile.first
      expect(patient.patient_profile.class.name).to eq('PatientProfile')
      expect(patient_profile.patient_id).to eq(patient.id)
    end

  end
  describe "#create" do
    it "automatically creates a User with the type 'Patient'" do
      patient = Patient.create(first_name: 'Test', last_name: 'Tester')
      expect(User.last).to eq(patient)
      expect(User.last.type).to eq('Patient')
    end

    it "allows for patient_profile_attributes to be included in instantiation" do
      dob     = Date.today
      patient = Patient.create(
        first_name: 'Test', last_name: 'Tester',
        patient_profile_attributes: {dob: dob, record_number: 123}
      )
      expect(patient.dob).to eq(dob)
      expect(patient.record_number).to eq(123)
      expect(patient.patient_profile.id).not_to eq(nil)
      expect(Patient.all.length).to eq(1)
    end

    it "has a patient profile with the join on its uuid" do
      dob     = Date.today
      patient = Patient.create(
        first_name: 'Test', last_name: 'Tester',
        patient_profile_attributes: {dob: dob, record_number: 123}
      )
      expect(patient.patient_profile.patient_id).to eq(patient.id)
    end
  end
  describe "#find_by_record_number" do
    before(:each) do
      @patient = FactoryGirl.create(:patient)
    end

    it "takes a string" do
      record_number = @patient.record_number.to_s
      result = Patient.find_by_record_number(record_number)
      expect(result.id).to eq(@patient.id)
    end
    it "takes an integer" do
      record_number = @patient.record_number.to_i
      result = Patient.find_by_record_number(record_number)
      expect(result.id).to eq(@patient.id)
    end
    it "returns nil when no patient is found" do
      result = Patient.find_by_record_number('9876')
      expect(result).to eq(nil)
    end
  end
  describe "#check_immunizations" do
    before(:each) do
      @patients = FactoryGirl.create_list(:patient, 10)
    end

    it "returns true if valid" do
      valid_imm = @patients[0].check_immunizations
      expect(valid_imm).to eq(true)
    end
    it "takes an integer" do
      record_number = @patient.record_number.to_i
      result = Patient.find_by_record_number(record_number)
      expect(result.id).to eq(@patient.id)
    end
    it "returns nil when no patient is found" do
      result = Patient.find_by_record_number('9876')
      expect(result).to eq(nil)
    end
  end


end
