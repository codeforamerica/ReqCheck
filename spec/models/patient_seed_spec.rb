require 'rails_helper'

RSpec.describe Patient, type: :model do
  describe "a valid patient with a valid vaccine doses history" do
    it "creates a valid patient with patient profile attributes" do
      dob     = in_pst(6.years.ago)
      patient = Patient.create(
        first_name: 'Test', last_name: 'Tester',
        patient_profile_attributes: {dob: dob, patient_number: 123}
      )
      expect(patient.dob).to eq(dob)
      expect(patient.patient_number).to eq(123)
      expect(patient.patient_profile.id).not_to eq(nil)
      expect(Patient.all.length).to eq(1)
    end
  end


end
