require 'rails_helper'

# up_to_date? could be checking if there are any eligible vaccines, and if none return true

RSpec.describe ImmunizationChecker, type: :model do
  # pass in requirements, immunizations, patient
  # returns immunization status of the patient
  
  describe '#up_to_date?' do
    it 'returns true if patient is up to date' do
      vaccine_code = 'DTaP'
      immunizations = [create(:immunization, vaccine_code: vaccine_code)]
      patient = immunizations.first.patient
      requirements = [create(:vaccine_requirement, vaccine_code: vaccine_code)]

      checker = ImmunizationChecker.new(
        requirements: requirements,
        immunizations: immunizations,
        patient: patient
      )

      expect(checker.up_to_date?).to be true
    end
    it 'returns false if patient has unmet requirement' do
      vaccine_code = 'DTaP'
      immunizations = []
      patient = create(:patient)
      requirements = [create(:vaccine_requirement, vaccine_code: vaccine_code)]

      checker = ImmunizationChecker.new(
        requirements: requirements,
        immunizations: immunizations,
        patient: patient
      )

      expect(checker.up_to_date?).to be false
    end
    it 'returns false if patient immunization vax code doesn\'t match requirement' do
      vaccine_code  = 'DTaP'
      vaccine_code2 = 'DTP'
      immunizations = [create(:immunization, vaccine_code: vaccine_code)]
      patient = immunizations.first.patient
      requirements = [create(:vaccine_requirement, vaccine_code: vaccine_code2)]

      checker = ImmunizationChecker.new(
        requirements: requirements,
        immunizations: immunizations,
        patient: patient
      )

      expect(checker.up_to_date?).to be false
    end
    it 'returns false if patient age > requirement min_age and no immunization' do
      immunizations = []
      patient = create(:patient_profile, dob: 5.years.ago.to_date).patient
      requirements = [create(:vaccine_requirement, min_age_years: 4)]

      checker = ImmunizationChecker.new(
        requirements: requirements,
        immunizations: immunizations,
        patient: patient
      )

      expect(checker.up_to_date?).to be false
    end
    it 'returns true if patient age < requirement min_age and no immunization' do
      immunizations = []
      patient = create(:patient_profile, dob: 4.years.ago.to_date).patient
      requirements = [create(:vaccine_requirement, min_age_years: 5)]

      checker = ImmunizationChecker.new(
        requirements: requirements,
        immunizations: immunizations,
        patient: patient
      )

      expect(checker.up_to_date?).to be true
    end

  end

  # Write tests for eligible_requirements

end
