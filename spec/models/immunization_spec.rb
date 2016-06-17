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
  describe '#patient_age_at_immunization' do
    let(:test_immunization) do
      patient = Patient.create(
        first_name: 'Test', last_name: 'Tester',
        patient_profile_attributes: {dob: 6.years.ago.to_date, record_number: 123}
      )
      Immunization.create(vaccine_code: 'VAR1',
        imm_date: Date.yesterday, patient_profile: patient.patient_profile
      )
    end
    it "gives the patients age at the date of the immunization" do
      new_time = Time.local(2016, 1, 3, 10, 0, 0)
      Timecop.freeze(new_time) do
        expect(test_immunization.patient_age_at_immunization.class.name).to eq('String')
        expect(test_immunization.patient_age_at_immunization).to eq('5y, 11m, 4w')
        # expect(test_immunization.patient_age_at_immunization).to eq('5 years, 11 months, 4 weeks')
      end
    end
    it "is formated as 1 year, 1 month and 1 week" do
    # ! Do we want it in this format, or should we have it as 1 year, 1 month and 1 week?
    # Logic for the immunization checker but will be using years, months and weeks
      new_time = Time.local(2016, 1, 3, 10, 0, 0)
      Timecop.freeze(new_time) do
        # expect(test_immunization.patient_age_at_immunization).to eq('5 years, 11 months, 4 weeks')
        expect(test_immunization.patient_age_at_immunization).to eq('5y, 11m, 4w')
      end
    end
  end
end
