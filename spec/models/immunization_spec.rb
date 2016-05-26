require 'rails_helper'

RSpec.describe Immunization, type: :model do
  it "does not require a Patient to be instantiated" do
    patient = Patient.create(
        first_name: 'Test', last_name: 'Tester',
        patient_profile_attributes: {dob: Date.today, record_number: 123}
      )
    immunization = Immunization.create(vaccine_code: 'VAR1',
      imm_date: Date.today
    )
    expect(immunization.type).to eq('Immunization')
  end

  it "does not require a Patient to be instantiated" do
    patient = Patient.create(
        first_name: 'Test', last_name: 'Tester',
        patient_profile_attributes: {dob: Date.today, record_number: 123}
      )
    immunization = Immunization.create(vaccine_code: 'VAR1',
      imm_date: Date.today, patient: patient
    )
    expect(immunization.type).to eq('Immunization')
  end
end
