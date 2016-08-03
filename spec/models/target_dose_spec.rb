require 'rails_helper'

RSpec.describe TargetDose, type: :model do
  describe 'validations' do
    let(:test_patient) { FactoryGirl.create(:patient) }
    let(:antigen_series_dose) { FactoryGirl.create(:antigen_series_dose) }
    it 'takes a patient and antigen_series_dose as parameters' do
      expect(
        TargetDose.new(antigen_series_dose: antigen_series_dose,
                       patient: test_patient).class.name
      ).to eq('TargetDose')
    end

    it 'requires a patient object' do
      expect{TargetDose.new(antigen_series_dose: antigen_series_dose)}.to raise_exception
    end
    it 'requires an antigen_series_dose' do
      expect{TargetDose.new(patient: test_patient)}.to raise_exception
    end
  end
  
  describe 'tests needing the antigen_series database' do
    before(:all) { FactoryGirl.create(:seed_antigen_xml) }
    after(:all) { DatabaseCleaner.clean_with(:truncation) }

    let(:test_patient) { FactoryGirl.create(:patient) }
    let(:as_dose) { AntigenSeriesDose.find_by() }
    let(:test_target_dose) do
      TargetDose.new(antigen_series_dose: as_dose, patient: test_patient)
    end

    describe 'target dose attributes from the antigen_series_dose' do
      dose_attributes = ['dose_number', 'absolute_min_age', 'min_age', 'earliest_recommended_age',
                         'latest_recommended_age', 'max_age', 'allowable_interval_type',
                         'allowable_interval_absolute_min', 'required_gender', 'recurring_dose',
                         'intervals']

      dose_attributes.each do | dose_attribute |
        it "has the attribute #{dose_attribute}" do
          expect(test_target_dose.antigen_series_dose).not_to eq(nil)
          expect(test_target_dose.send(dose_attribute)).to eq(as_dose.send(dose_attribute))
        end
      end

      it 'has a dose number' do
        expect(test_target_dose.dose_number).to eq(1)
      end
    end

    describe '#age_eligible?' do
      it 'sets the @eligible? attribute to true if the target_dose is eligible' do
        expect(test_target_dose.eligible).to eq(nil)
        test_target_dose.age_eligible?(test_patient.dob)
        expect(test_target_dose.eligible).to eq(true)
      end
      it 'sets the @eligible? attribute to false if the target_dose is ineligible' do
        expect(test_target_dose.eligible).to eq(nil)
        byebug
        test_target_dose.age_eligible?(1.day.ago.to_date)
        expect(test_target_dose.eligible).to eq(false)
      end
      it 'checks agains max age' do
        test_target_dose.antigen_series_dose.max_age = '18 years'
        expect(test_target_dose.max_age).to eq('18 years')
        expect(test_target_dose.eligible).to eq(nil)
        test_target_dose.age_eligible?(19.years.ago.to_date)
        expect(test_target_dose.eligible).to eq(false)
      end
      it 'can handle the max age being nil' do
        expect(test_target_dose.max_age).to eq(nil)
        expect(test_target_dose.eligible).to eq(nil)
        test_target_dose.age_eligible?(19.years.ago.to_date)
        expect(test_target_dose.eligible).to eq(true)
      end
    end

    describe '#evaluate_antigen_administered_record' do
      # let(:vaccine_dose) { FactoryGirl.create(:vaccine_dose, patient_profile: test_patient.patient_profile, vaccine_code:  }
      # let(:aar) { AntigenAdministeredRecord.create_records_from_vaccine_doses() }
      # expect(test_target_dose.evaluate_antigen_administered_record()
      it 'is a test' do
        asdose = antigen_series_dose
        byebug
      end

    end

  # describe '#required_for_patient' do
  #   let(:test_patient) { FactoryGirl.create(:patient_profile, dob: 2.years.ago).patient }
  #   let(:antigen_series_dose) { FactoryGirl.create(:antigen_series_dose) }

  #   it 'checks if the target_dose is required for the patient and returns boolean' do
  #     target_dose = TargetDose.new(patient: test_patient, antigen_series_dose: antigen_series_dose)
  #     expect(target_dose.required_for_patient).to eq(true)
  #   end
  #   it 'returns false if the antigen_series_dose dose not satisfy the ' do
  #     target_dose = TargetDose.new(patient: test_patient, antigen_series_dose: antigen_series_dose)
  #     expect(target_dose.required_for_patient).to eq(true)
  #   end
  # end
  end
end
