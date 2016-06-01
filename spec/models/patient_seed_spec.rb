require 'rails_helper'

RSpec.describe Patient, type: :model do
  describe "a valid patient with a valid immunization history" do
    dob     = Date.strptime("2010")
    patient = Patient.create(
      first_name: 'Test', last_name: 'Tester',
      patient_profile_attributes: {dob: dob, record_number: 123}
    )
    expect(patient.dob).to eq(dob)
    expect(patient.record_number).to eq(123)
    expect(patient.patient_profile.id).not_to eq(nil)
    expect(Patient.all.length).to eq(1)

  end


end