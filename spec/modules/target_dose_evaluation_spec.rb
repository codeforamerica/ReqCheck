require 'rails_helper'
require 'target_dose_evaluation'

RSpec.describe TargetDoseEvaluation do
  before(:all) { FactoryGirl.create(:seed_antigen_xml_polio) }
  after(:all) { DatabaseCleaner.clean_with(:truncation) }

  let(:test_object) do
    class TestClass
      include TargetDoseEvaluation
    end
    TestClass.new
  end

  let(:conditional_skip_object) do
    FactoryGirl.create(:conditional_skip)
  end

  let(:as_dose_object) do
    FactoryGirl.create(:antigen_series_dose_with_vaccines)
  end

  let(:second_as_dose_object) do
    FactoryGirl.create(:antigen_series_dose_second_with_vaccines)
  end

  let(:test_patient) do
    test_patient = FactoryGirl.create(:patient)
    FactoryGirl.create(
      :vaccine_dose_by_cvx,
      patient_profile: test_patient.patient_profile,
      cvx_code: as_dose_object.preferable_vaccines.first.cvx_code,
      date_administered: (test_patient.dob + 7.weeks)
    )
    FactoryGirl.create(
      :vaccine_dose_by_cvx,
      patient_profile: test_patient.patient_profile,
      cvx_code: as_dose_object.preferable_vaccines.first.cvx_code,
      date_administered: (test_patient.dob + 11.weeks)
    )
    test_patient.reload
    test_patient
  end

  let(:interval_objects) do
    second_as_dose_object.intervals
  end

  describe '#evaluate_target_dose_satisfied' do
    test_description = 'takes a conditional_skip_object, ' \
       'antigen_series_dose_object, interval_objects, ' \
       'antigen_series_dose_vaccines, patient_dob, patient_gender, ' \
       'patient_vaccine_doses, date_of_dose, dose_volume, dose_trade_name, ' \
       'date_of_previous_dose, previous_dose_status_hash ' \
       'and returns a status_hash'
    it test_description do
      patient_vaccines    = test_patient.vaccine_doses
      first_vaccine_dose  = patient_vaccines[0]
      second_vaccine_dose = patient_vaccines[1]
      patient_dob         = test_patient.dob
      patient_gender      = test_patient.gender

      expected_result = {
        status: 'satisfied',
        details: 'on_schedule'
      }

      evaluation_hash = test_object.evaluate_target_dose_satisfied(
        conditional_skip: conditional_skip_object,
        antigen_series_dose: as_dose_object,
        intervals: [],
        antigen_series_dose_vaccines: as_dose_object.dose_vaccines,
        patient_dob: patient_dob,
        patient_gender: patient_gender,
        patient_vaccine_doses: patient_vaccines,
        dose_cvx: first_vaccine_dose.cvx_code,
        date_of_dose: first_vaccine_dose.date_administered,
        dose_volume: first_vaccine_dose.dosage,
        dose_trade_name: '',
        date_of_previous_dose: nil,
        previous_dose_status_hash: nil
      )
      expect(evaluation_hash).to eq(expected_result)
    end
    it 'can evaluate the second dose with the previous status hash' do
      patient_vaccines     = test_patient.vaccine_doses
      first_vaccine_dose   = patient_vaccines[0]
      second_vaccine_dose  = patient_vaccines[1]
      patient_dob          = test_patient.dob
      patient_gender       = test_patient.gender

      previous_status_hash = {
        status: 'valid',
        details: 'on_schedule'
      }
      expected_result = {
        status: 'satisfied',
        details: 'on_schedule'
      }

      evaluation_hash = test_object.evaluate_target_dose_satisfied(
        conditional_skip: conditional_skip_object,
        antigen_series_dose: as_dose_object,
        intervals: [],
        antigen_series_dose_vaccines: as_dose_object.dose_vaccines,
        patient_dob: patient_dob,
        patient_gender: patient_gender,
        patient_vaccine_doses: patient_vaccines,
        dose_cvx: second_vaccine_dose.cvx_code,
        date_of_dose: second_vaccine_dose.date_administered,
        dose_volume: second_vaccine_dose.dosage,
        dose_trade_name: '',
        date_of_previous_dose: first_vaccine_dose.date_administered,
        previous_dose_status_hash: previous_status_hash
      )
      expect(evaluation_hash).to eq(expected_result)
    end
  end
end

      # Evaluate Conditional Skip
      # Evaluate Age
      # Evaluate Interval
      # Evaluate Allowable Interval
      # Evaluate Live Virus Conflict
      # Evaluate Preferable Vaccine
      # Evaluate Allowable Vaccine
      # Evaluate Gender
      # Satisfy Target Dose
