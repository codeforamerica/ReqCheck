require 'rails_helper'

RSpec.describe Patient, type: :model do
  before do
    new_time = Time.local(2016, 1, 3, 10, 0, 0)
    Timecop.freeze(new_time)
  end

  after do
    Timecop.return
  end

  describe "test the factory first" do
    it "has a patient profile automatically created" do
      patient = FactoryGirl.create(:patient)
      patient_profile = PatientProfile.first
      expect(patient.patient_profile.class.name).to eq('PatientProfile')
      expect(patient_profile.patient_id).to eq(patient.id)
    end
0
  end
  describe "#create" do
    it "automatically creates a User with the type 'Patient'" do
      patient = Patient.create(first_name: 'Test', last_name: 'Tester')
      expect(User.last).to eq(patient)
      expect(User.last.type).to eq('Patient')
    end

    it "allows for patient_profile_attributes to be included in instantiation" do
      dob     = in_pst(Date.today)
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
      dob     = in_pst(Date.today)
      patient = Patient.create(
        first_name: 'Test', last_name: 'Tester',
        patient_profile_attributes: {dob: dob, record_number: 123}
      )
      expect(patient.patient_profile.patient_id).to eq(patient.id)
    end
    xit "has an immunization_checker attribute which is an ImmunizationChecker object" do
      dob     = in_pst(Date.today)
      patient = Patient.create(
        first_name: 'Test', last_name: 'Tester',
        patient_profile_attributes: {dob: dob, record_number: 123}
      )
      expect(patient.immunization_checker.class.name).to eq("ImmunizationChecker")
    end
    it "has an immunizations attribute" do
      dob     = in_pst(Date.today)
      patient = Patient.create(
        first_name: 'Test', last_name: 'Tester',
        patient_profile_attributes: {dob: dob, record_number: 123}
      )
      immunization = FactoryGirl.create(:immunization, patient: patient)
      expect(patient.immunizations.length).to eq(1)
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
  xdescribe "#check_record" do
    before(:each) do
      @patients = FactoryGirl.create_list(:patient, 10)
    end

    xit "returns true if valid" do
      valid_imm = @patients[0].check_record
      expect(valid_imm).to eq(true)
    end

    xit "returns false if invalid" do
      invalid_patient = FactoryGirl.create(:patient)
      invalid_imm = invalid_patient.check_record
      expect(invalid_imm).to eq(false)
    end
  end
  describe "#age_in_days" do
    it "returns the patients age in days" do
      patient = FactoryGirl.create(:patient,
        patient_profile_attributes: {dob: in_pst(5.years.ago), record_number: 123}
      )
      days_age = patient.age_in_days
      expect(days_age).to eq((365 * 5) + 1)
    end
  end
  describe "#age" do
    let(:age_patient) do
      FactoryGirl.create(:patient,
        patient_profile_attributes: {dob: in_pst(5.years.ago), record_number: 123}
      )
    end
    it "has a dob attribute" do
      expect(age_patient.dob.class.name).to eq('Date')
    end
    it "returns the patients age in years" do
      pat_age = age_patient.age
      expect(pat_age).to eq(5)
      expect(pat_age.is_a? Integer).to be(true)
    end
    it "is exact to the day if the birthday is a day earlier" do
      patient = FactoryGirl.create(:patient,
        patient_profile_attributes: {dob: in_pst(5.years.ago), record_number: 123}
      )
      new_date = patient.patient_profile.dob - 1
      patient.patient_profile.update(dob: new_date)
      pat_age = patient.age
      expect(pat_age).to eq(5)
    end
    it "is exact to the day if the birthday is a day earlier" do
      patient = FactoryGirl.create(:patient,
        patient_profile_attributes: {dob: in_pst(5.years.ago), record_number: 123}
      )
      new_date = patient.patient_profile.dob + 1
      patient.patient_profile.update(dob: new_date)
      pat_age = patient.age
      expect(pat_age).to eq(4)
    end
  end


end
