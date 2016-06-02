require 'rails_helper'

RSpec.describe Immunization, type: :model do
  it "does not require a Patient to be instantiated" do
    immunization = Immunization.create(vaccine_code: 'VAR1',
      imm_date: Date.today
    )
    expect(immunization.class.name).to eq('Immunization')
  end

  it "can take a Patient object as a parameter" do
    patient = Patient.create(
        first_name: 'Test', last_name: 'Tester',
        patient_profile_attributes: {dob: Date.today, record_number: 123}
      )
    immunization = Immunization.create(vaccine_code: 'VAR1',
      imm_date: Date.today, patient_profile: patient.patient_profile
    )
    expect(immunization.class.name).to eq('Immunization')
  end
end
