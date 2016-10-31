require 'rails_helper'

RSpec.describe Patient, type: :model do
  describe 'a valid patient with a valid vaccine doses history' do
    it 'creates a valid patient with required attributes' do
      dob     = 6.years.ago.to_date
      patient = Patient.create(
        first_name: 'Test', last_name: 'Tester',
        dob: dob, patient_number: 123
      )
      expect(patient.dob).to eq(dob)
      expect(patient.patient_number).to eq(123)
      expect(Patient.all.length).to eq(1)
    end
  end
end
