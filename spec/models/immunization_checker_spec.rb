require 'rails_helper'

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
  describe "#eligible_vaccinations" do
    it "returns an empty array if the requirements are met" do
      vaccine_code = 'DTaP'
      immunizations = [create(:immunization, vaccine_code: vaccine_code)]
      patient = create(:patient_profile, dob: 5.years.ago.to_date).patient
      requirements = [create(:vaccine_requirement, vaccine_code: vaccine_code, min_age_years: 5)]

      checker = ImmunizationChecker.new(
        requirements: requirements,
        immunizations: immunizations,
        patient: patient
      )

      expect(checker.eligible_vaccinations).to eq([])
    end
    it "returns a requirement if there is an unmet requirements" do
      immunizations = []
      patient = create(:patient_profile, dob: 5.years.ago.to_date).patient
      requirements = [create(:vaccine_requirement, min_age_years: 5)]

      checker = ImmunizationChecker.new(
        requirements: requirements,
        immunizations: immunizations,
        patient: patient
      )

      expect(checker.eligible_vaccinations.length).to eq(1)
      expect(checker.eligible_vaccinations[0].class.name).to eq('VaccineRequirement')
    end
    it "returns the second requirement if second immunization not given" do
      vaccine_code          = 'DTaP'
      first_age_min_weeks   = 6
      second_age_min_weeks  = 10
      second_time_min_weeks = 4
      patient_profile = create(:patient_profile, dob: 12.weeks.ago.to_date)
      immunizations = [
        create(:immunization,
          vaccine_code: vaccine_code,
          patient_profile_id: patient_profile.id,
          imm_date: 5.weeks.ago.to_date
        )
      ]
      requirements = [
        create(:vaccine_requirement,
          min_age_weeks: first_age_min_weeks,
          vaccine_code: vaccine_code
        ),
        create(:vaccine_requirement,
          min_age_weeks: second_age_min_weeks,
          dosage_number: 2,
          vaccine_code: vaccine_code
        )
      ]
      create(:vaccine_requirement_detail,
        required_weeks: second_time_min_weeks,
        requirer_id: requirements[1].id,
        requirement_id: requirements[0].id
      )

      checker = ImmunizationChecker.new(
        requirements: requirements,
        immunizations: immunizations,
        patient: patient_profile.patient
      )

      expect(checker.eligible_vaccinations.length).to eq(1)
      expect(checker.eligible_vaccinations[0].dosage).to eq(2)
      expect(checker.eligible_vaccinations[0].vaccine_code).to eq(vaccine_code)
    end
  end

  # Write tests for eligible_vaccinations

end
