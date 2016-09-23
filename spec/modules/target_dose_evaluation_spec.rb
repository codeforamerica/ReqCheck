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
    test_patient = FactoryGirl.create(:patient_with_profile)
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
        evaluation_status: 'valid',
        target_dose_status: 'satisfied',
        details: {
          age: 'on_schedule',
          preferable_intervals: ['no_intervals_required'],
          allowable_intervals: ['no_intervals_required'],
          allowable: 'within_age_range'
        }
      }

      evaluation_hash = test_object.evaluate_target_dose_satisfied(
        conditional_skip: conditional_skip_object,
        antigen_series_dose: as_dose_object,
        preferable_intervals: [],
        allowable_intervals: [],
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
        evaluation_status: 'valid',
        target_dose_status: 'satisfied',
        details: 'on_schedule'
      }
      expected_result = {
        evaluation_status: 'valid',
        target_dose_status: 'satisfied',
        details: {
          age: 'on_schedule',
          preferable_intervals: ['no_intervals_required'],
          allowable_intervals: ['no_intervals_required'],
          allowable: 'within_age_range'
        }
      }

      evaluation_hash = test_object.evaluate_target_dose_satisfied(
        conditional_skip: conditional_skip_object,
        antigen_series_dose: as_dose_object,
        preferable_intervals: [],
        allowable_intervals: [],
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
    xcontext 'when conditional_skip is not_valid' do
    end
    context 'when age is not_valid' do
      it 'returns satisfied for first dose age valid' do
        patient_vaccines     = test_patient.vaccine_doses
        vaccine_dose         = patient_vaccines[0]
        patient_dob          =
          (vaccine_dose.date_administered - 6.weeks + 1.day)
        patient_gender       = test_patient.gender

        previous_status_hash = nil
        expected_result = {
          evaluation_status: 'valid',
          target_dose_status: 'satisfied',
          details: {
            age: 'grace_period',
            preferable_intervals: ['no_intervals_required'],
            allowable_intervals: ['no_intervals_required'],
            allowable: 'within_age_range'
          }
        }

        evaluation_hash = test_object.evaluate_target_dose_satisfied(
          conditional_skip: conditional_skip_object,
          antigen_series_dose: as_dose_object,
          preferable_intervals: [],
          allowable_intervals: [],
          antigen_series_dose_vaccines: as_dose_object.dose_vaccines,
          patient_dob: patient_dob,
          patient_gender: patient_gender,
          patient_vaccine_doses: patient_vaccines,
          dose_cvx: vaccine_dose.cvx_code,
          date_of_dose: vaccine_dose.date_administered,
          dose_volume: vaccine_dose.dosage,
          dose_trade_name: '',
          date_of_previous_dose: nil,
          previous_dose_status_hash: previous_status_hash
        )
        expect(evaluation_hash).to eq(expected_result)
      end
      it 'returns not_satisfied for first dose age not_valid' do
        patient_vaccines     = test_patient.vaccine_doses
        vaccine_dose         = patient_vaccines[0]
        patient_dob          = (vaccine_dose.date_administered - 5.weeks)
        patient_gender       = test_patient.gender

        previous_status_hash = nil
        expected_result = {
          evaluation_status: 'not_valid',
          target_dose_status: 'not_satisfied',
          reason: 'age',
          details: {
            age: 'too_young'
          }
        }

        evaluation_hash = test_object.evaluate_target_dose_satisfied(
          conditional_skip: conditional_skip_object,
          antigen_series_dose: as_dose_object,
          preferable_intervals: [],
          allowable_intervals: [],
          antigen_series_dose_vaccines: as_dose_object.dose_vaccines,
          patient_dob: patient_dob,
          patient_gender: patient_gender,
          patient_vaccine_doses: patient_vaccines,
          dose_cvx: vaccine_dose.cvx_code,
          date_of_dose: vaccine_dose.date_administered,
          dose_volume: vaccine_dose.dosage,
          dose_trade_name: '',
          date_of_previous_dose: nil,
          previous_dose_status_hash: previous_status_hash
        )
        expect(evaluation_hash).to eq(expected_result)
      end
      it 'returns not_satisfied for second age not_valid and first not_valid' do
        patient_vaccines     = test_patient.vaccine_doses
        first_vaccine_dose   = patient_vaccines[0]
        second_vaccine_dose  = patient_vaccines[1]
        patient_dob          =
          (second_vaccine_dose.date_administered - 6.weeks + 1.day)
        patient_gender       = test_patient.gender

        previous_status_hash = {
          evaluation_status: 'not_valid',
          target_dose_status: 'not_satisfied',
          reason: 'age',
          details: {
            age: 'too_young'
          }
        }
        expected_result = {
          evaluation_status: 'not_valid',
          target_dose_status: 'not_satisfied',
          reason: 'age',
          details: {
            age: 'too_young'
          }
        }

        evaluation_hash = test_object.evaluate_target_dose_satisfied(
          conditional_skip: conditional_skip_object,
          antigen_series_dose: as_dose_object,
          preferable_intervals: [],
          allowable_intervals: [],
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
      it 'returns satisfied for second age not_valid but first valid' do
        patient_vaccines     = test_patient.vaccine_doses
        first_vaccine_dose   = patient_vaccines[0]
        second_vaccine_dose  = patient_vaccines[1]
        patient_dob          =
          (second_vaccine_dose.date_administered - 6.weeks + 1.day)
        patient_gender       = test_patient.gender

        previous_status_hash = {
          evaluation_status: 'valid',
          target_dose_status: 'satisfied',
        }
        expected_result = {
          evaluation_status: 'valid',
          target_dose_status: 'satisfied',
          details: {
            age: 'grace_period',
            preferable_intervals: ['no_intervals_required'],
            allowable_intervals: ['no_intervals_required'],
            allowable: 'within_age_range'
          }
        }

        evaluation_hash = test_object.evaluate_target_dose_satisfied(
          conditional_skip: conditional_skip_object,
          antigen_series_dose: as_dose_object,
          preferable_intervals: [],
          allowable_intervals: [],
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
    context 'when preferable_interval is not_valid' do
      let(:test_preferable_intervals) do
        [
          FactoryGirl.create(:interval_6_months),
          FactoryGirl.create(:interval_target_dose_16_weeks),
        ]
      end

      it 'returns not_satisfied less time between interval and no allowable' do
        patient_vaccines     = test_patient.vaccine_doses
        first_vaccine_dose   = patient_vaccines[0]
        second_vaccine_dose  = patient_vaccines[1]
        patient_dob          = test_patient.dob
        patient_gender       = test_patient.gender
        new_intervals        = [test_preferable_intervals.first]

        expect(new_intervals.first.interval_absolute_min)
          .to eq('6 months - 4 days')

        second_vaccine_dose.update(
          date_administered: (first_vaccine_dose.date_administered + 2.weeks)
        )

        previous_status_hash = {
          evaluation_status: 'valid',
          target_dose_status: 'satisfied',
        }
        expected_result = {
          evaluation_status: 'not_valid',
          target_dose_status: 'not_satisfied',
          reason: 'interval',
          details: {
            age: 'on_schedule',
            preferable_intervals: ['too_soon'],
            allowable_intervals: ['no_intervals_required']
          }
        }

        evaluation_hash = test_object.evaluate_target_dose_satisfied(
          conditional_skip: conditional_skip_object,
          antigen_series_dose: as_dose_object,
          preferable_intervals: new_intervals,
          allowable_intervals: [],
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
      it 'returns satisfied more time between interval' do
        patient_vaccines     = test_patient.vaccine_doses
        first_vaccine_dose   = patient_vaccines[0]
        second_vaccine_dose  = patient_vaccines[1]
        patient_dob          = test_patient.dob
        patient_gender       = test_patient.gender
        new_intervals        = [test_preferable_intervals.first]

        expect(new_intervals.first.interval_absolute_min)
          .to eq('6 months - 4 days')

        second_vaccine_dose.update(
          date_administered: (first_vaccine_dose.date_administered + 6.months)
        )

        previous_status_hash = {
          evaluation_status: 'valid',
          target_dose_status: 'satisfied',
        }
        expected_result = {
          evaluation_status: 'valid',
          target_dose_status: 'satisfied',
          details: {
            age: 'on_schedule',
            preferable_intervals: ['on_schedule'],
            allowable_intervals: ['no_intervals_required'],
            allowable: 'within_age_range'
          }
        }

        evaluation_hash = test_object.evaluate_target_dose_satisfied(
          conditional_skip: conditional_skip_object,
          antigen_series_dose: as_dose_object,
          preferable_intervals: new_intervals,
          allowable_intervals: [],
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
      it 'returns not_satisfied more time between intervals but ' \
         'previous evaluation_status was not_valid due to age' do
        patient_vaccines     = test_patient.vaccine_doses
        first_vaccine_dose   = patient_vaccines[0]
        second_vaccine_dose  = patient_vaccines[1]
        patient_dob          = test_patient.dob
        patient_gender       = test_patient.gender
        new_intervals        = [test_preferable_intervals.first]

        expect(new_intervals.first.interval_min).to eq('6 months')
        expect(new_intervals.first.interval_absolute_min)
          .to eq('6 months - 4 days')
        second_vaccine_dose.update(
          date_administered: (
            first_vaccine_dose.date_administered + 6.months - 2.days
          )
        )

        previous_status_hash = {
          evaluation_status: 'not_valid',
          target_dose_status: 'not_satisfied',
          reason: 'age'
        }
        expected_result = {
          evaluation_status: 'not_valid',
          target_dose_status: 'not_satisfied',
          reason: 'interval',
          details: {
            age: 'on_schedule',
            preferable_intervals: ['too_soon'],
            allowable_intervals: ['no_intervals_required']
          }
        }

        evaluation_hash = test_object.evaluate_target_dose_satisfied(
          conditional_skip: conditional_skip_object,
          antigen_series_dose: as_dose_object,
          preferable_intervals: new_intervals,
          allowable_intervals: [],
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
      it 'returns satisfied more time between intervals but ' \
         'previous evaluation_status was valid due to age' do
        patient_vaccines     = test_patient.vaccine_doses
        first_vaccine_dose   = patient_vaccines[0]
        second_vaccine_dose  = patient_vaccines[1]
        patient_dob          = test_patient.dob
        patient_gender       = test_patient.gender
        new_intervals        = [test_preferable_intervals.first]

        expect(new_intervals.first.interval_min).to eq('6 months')
        expect(new_intervals.first.interval_absolute_min)
          .to eq('6 months - 4 days')
        second_vaccine_dose.update(
          date_administered: (
            first_vaccine_dose.date_administered + 6.months - 2.days
          )
        )

        previous_status_hash = {
          evaluation_status: 'valid',
          target_dose_status: 'satisfied',
        }
        expected_result = {
          evaluation_status: 'valid',
          target_dose_status: 'satisfied',
          details: {
            age: 'on_schedule',
            preferable_intervals: ['grace_period'],
            allowable_intervals: ['no_intervals_required'],
            allowable: 'within_age_range'
          }
        }

        evaluation_hash = test_object.evaluate_target_dose_satisfied(
          conditional_skip: conditional_skip_object,
          antigen_series_dose: as_dose_object,
          preferable_intervals: new_intervals,
          allowable_intervals: [],
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
    context 'when allowable interval is not_valid' do
      let(:test_allowable_intervals) do
        [
          FactoryGirl.create(:interval_6_months, allowable: true),
          FactoryGirl.create(:interval_4_months_allowable)
        ]
      end
      it 'returns not_satisfied less time between allowable intervals' do
        patient_vaccines     = test_patient.vaccine_doses
        first_vaccine_dose   = patient_vaccines[0]
        second_vaccine_dose  = patient_vaccines[1]
        patient_dob          = test_patient.dob
        patient_gender       = test_patient.gender
        second_vaccine_dose.update(
          date_administered: (first_vaccine_dose.date_administered + 2.weeks)
        )

        previous_status_hash = {
          evaluation_status: 'valid',
          target_dose_status: 'satisfied',
        }
        expected_result = {
          evaluation_status: 'not_valid',
          target_dose_status: 'not_satisfied',
          reason: 'interval',
          details: {
            age: 'on_schedule',
            preferable_intervals: ['no_intervals_required'],
            allowable_intervals: ['too_soon', 'too_soon']
          }
        }

        evaluation_hash = test_object.evaluate_target_dose_satisfied(
          conditional_skip: conditional_skip_object,
          antigen_series_dose: as_dose_object,
          preferable_intervals: [],
          allowable_intervals: test_allowable_intervals,
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
      it 'returns satisfied more time between allowable intervals' do
        patient_vaccines     = test_patient.vaccine_doses
        first_vaccine_dose   = patient_vaccines[0]
        second_vaccine_dose  = patient_vaccines[1]
        patient_dob          = test_patient.dob
        patient_gender       = test_patient.gender
        new_intervals        = [test_allowable_intervals.last]

        expect(new_intervals.first.interval_absolute_min)
          .to eq('4 months')

        second_vaccine_dose.update(
          date_administered: (first_vaccine_dose.date_administered + 4.months)
        )

        previous_status_hash = {
          evaluation_status: 'valid',
          target_dose_status: 'satisfied',
        }
        expected_result = {
          evaluation_status: 'valid',
          target_dose_status: 'satisfied',
          details: {
            age: 'on_schedule',
            preferable_intervals: ['no_intervals_required'],
            allowable_intervals: ['on_schedule'],
            allowable: 'within_age_range'
          }
        }

        evaluation_hash = test_object.evaluate_target_dose_satisfied(
          conditional_skip: conditional_skip_object,
          antigen_series_dose: as_dose_object,
          preferable_intervals: [],
          allowable_intervals: new_intervals,
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
      it 'returns not_satisfied even with interval_min_date defaulting ' \
         ' to 01/01/1900 as the interval_absolute_min is false' do
        patient_vaccines     = test_patient.vaccine_doses
        first_vaccine_dose   = patient_vaccines[0]
        second_vaccine_dose  = patient_vaccines[1]
        patient_dob          = test_patient.dob
        patient_gender       = test_patient.gender
        new_intervals        = [test_allowable_intervals.last]

        expect(new_intervals.first.interval_min).to eq('')
        expect(new_intervals.first.interval_absolute_min)
          .to eq('4 months')
        second_vaccine_dose.update(
          date_administered: (
            first_vaccine_dose.date_administered + 2.months
          )
        )

        previous_status_hash = {
          evaluation_status: 'not_valid',
          target_dose_status: 'not_satisfied',
          reason: 'age'
        }
        expected_result = {
          evaluation_status: 'not_valid',
          target_dose_status: 'not_satisfied',
          reason: 'interval',
          details: {
            age: 'on_schedule',
            preferable_intervals: ['no_intervals_required'],
            allowable_intervals: ['too_soon']
          }
        }

        evaluation_hash = test_object.evaluate_target_dose_satisfied(
          conditional_skip: conditional_skip_object,
          antigen_series_dose: as_dose_object,
          preferable_intervals: [],
          allowable_intervals: new_intervals,
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
      it 'returns satisfied as interval_absolute_min is true and ' \
         ' interval_min_date defaults to 01/01/1900 even with previous' \
         ' evaluation_status was not_valid due to age' do
        # This needs to be completed - currently it does not give grace period
        # bc the default evaluates the min_age to be way before (1900)
        patient_vaccines     = test_patient.vaccine_doses
        first_vaccine_dose   = patient_vaccines[0]
        second_vaccine_dose  = patient_vaccines[1]
        patient_dob          = test_patient.dob
        patient_gender       = test_patient.gender
        new_intervals        = [test_allowable_intervals.last]

        expect(new_intervals.first.interval_min).to eq('')
        expect(new_intervals.first.interval_absolute_min)
          .to eq('4 months')
        second_vaccine_dose.update(
          date_administered: (
            first_vaccine_dose.date_administered + 4.months
          )
        )

        previous_status_hash = {
          evaluation_status: 'not_valid',
          target_dose_status: 'not_satisfied',
          reason: 'age'
        }
        expected_result = {
          evaluation_status: 'valid',
          target_dose_status: 'satisfied',
          details: {
            age: 'on_schedule',
            preferable_intervals: ['no_intervals_required'],
            allowable_intervals: ['grace_period'],
            allowable: 'within_age_range'
          }
        }

        evaluation_hash = test_object.evaluate_target_dose_satisfied(
          conditional_skip: conditional_skip_object,
          antigen_series_dose: as_dose_object,
          preferable_intervals: [],
          allowable_intervals: new_intervals,
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
        expect('').to eq(
          'Need to ensure that this is what is supposed to happen - this' \
          'could mean that the something that does not make the min age' \
          'on the allowable interval and then with the default could give' \
          'a falst positive'
        )
      end
    end
    context 'when preferable vaccine is not_valid and no allowable' do
      let(:test_patient) do
        test_patient = FactoryGirl.create(:patient_with_profile)
        FactoryGirl.create(
          :vaccine_dose_by_cvx,
          patient_profile: test_patient.patient_profile,
          cvx_code: as_dose_object.preferable_vaccines.last.cvx_code,
          date_administered: (test_patient.dob + 7.weeks)
        )
        FactoryGirl.create(
          :vaccine_dose_by_cvx,
          patient_profile: test_patient.patient_profile,
          cvx_code: as_dose_object.preferable_vaccines.last.cvx_code,
          date_administered: (test_patient.dob + 11.weeks)
        )
        test_patient.reload
        test_patient
      end

      it 'ensures the vaccine codes are in preferable cdc as_dose ' \
         'vaccine codes but not allowable cdc as_dose vaccine codes' do
        preferable_cvx_codes = as_dose_object.preferable_vaccines.map(&:cvx_code)
        allowable_cvx_codes  = as_dose_object.allowable_vaccines.map(&:cvx_code)
        test_patient.vaccine_doses.each do |vaccine_dose|
          expect(preferable_cvx_codes).to include(vaccine_dose.cvx_code)
          expect(allowable_cvx_codes).not_to include(vaccine_dose.cvx_code)
        end
      end
      it 'returns not_satisfied when the preferable vaccine age is not_valid' do
        patient_vaccines     = test_patient.vaccine_doses
        vaccine_dose         = patient_vaccines[0]
        patient_dob          =
          (vaccine_dose.date_administered - 6.weeks + 5.days)
        patient_gender       = test_patient.gender
        as_dose_object.absolute_min_age = '1 week'

        expect(vaccine_dose.cvx_code).to eq(110)

        preferable_dose = as_dose_object.preferable_vaccines.find do |dose|
          dose.cvx_code == vaccine_dose.cvx_code
        end

        expect(preferable_dose.begin_age).to eq('6 weeks')

        previous_status_hash = nil
        expected_result = {
          evaluation_status: 'not_valid',
          target_dose_status: 'not_satisfied',
          reason: 'preferable_vaccine_evaluation',
          details: {
            age: 'grace_period',
            preferable_intervals: ['no_intervals_required'],
            allowable_intervals: ['no_intervals_required'],
            preferable: 'out_of_age_range'
          }
        }

        evaluation_hash = test_object.evaluate_target_dose_satisfied(
          conditional_skip: conditional_skip_object,
          antigen_series_dose: as_dose_object,
          preferable_intervals: [],
          allowable_intervals: [],
          antigen_series_dose_vaccines: as_dose_object.dose_vaccines,
          patient_dob: patient_dob,
          patient_gender: patient_gender,
          patient_vaccine_doses: patient_vaccines,
          dose_cvx: vaccine_dose.cvx_code,
          date_of_dose: vaccine_dose.date_administered,
          dose_volume: vaccine_dose.dosage,
          dose_trade_name: '',
          date_of_previous_dose: nil,
          previous_dose_status_hash: previous_status_hash
        )
        expect(evaluation_hash).to eq(expected_result)
      end
      it 'returns not_satisfied when the preferable vaccine trade_name is ' \
         'not_valid' do
        patient_vaccines     = test_patient.vaccine_doses
        vaccine_dose         = patient_vaccines[0]
        patient_dob          =
          (vaccine_dose.date_administered - 6.weeks)
        patient_gender       = test_patient.gender
        as_dose_object.absolute_min_age = '1 week'

        preferable_dose = as_dose_object.preferable_vaccines.find do |dose|
          dose.cvx_code == 110
        end

        preferable_dose.trade_name = 'not_test'

        expect(preferable_dose.begin_age).to eq('6 weeks')

        previous_status_hash = nil
        expected_result = {
          evaluation_status: 'not_valid',
          target_dose_status: 'not_satisfied',
          reason: 'preferable_vaccine_evaluation',
          details: {
            age: 'on_schedule',
            preferable_intervals: ['no_intervals_required'],
            allowable_intervals: ['no_intervals_required'],
            preferable: 'wrong_trade_name'
          }
        }

        evaluation_hash = test_object.evaluate_target_dose_satisfied(
          conditional_skip: conditional_skip_object,
          antigen_series_dose: as_dose_object,
          preferable_intervals: [],
          allowable_intervals: [],
          antigen_series_dose_vaccines: as_dose_object.dose_vaccines,
          patient_dob: patient_dob,
          patient_gender: patient_gender,
          patient_vaccine_doses: patient_vaccines,
          dose_cvx: vaccine_dose.cvx_code,
          date_of_dose: vaccine_dose.date_administered,
          dose_volume: vaccine_dose.dosage,
          dose_trade_name: 'test',
          date_of_previous_dose: nil,
          previous_dose_status_hash: previous_status_hash
        )
        expect(evaluation_hash).to eq(expected_result)
      end
      it 'returns satisfied when the preferable vaccine volume is not_valid' do
        patient_vaccines     = test_patient.vaccine_doses
        vaccine_dose         = patient_vaccines[0]
        vaccine_dose.dosage  = '0.4'
        patient_dob          =
          (vaccine_dose.date_administered - 6.weeks)
        patient_gender       = test_patient.gender
        as_dose_object.absolute_min_age = '1 week'

        preferable_dose = as_dose_object.preferable_vaccines.find do |dose|
          dose.cvx_code == 10
        end

        expect(preferable_dose.volume).to eq('0.5')
        expect(preferable_dose.begin_age).to eq('6 weeks')

        previous_status_hash = nil
        expected_result = {
          evaluation_status: 'valid',
          target_dose_status: 'satisfied',
          details: {
            age: 'on_schedule',
            preferable_intervals: ['no_intervals_required'],
            allowable_intervals: ['no_intervals_required'],
            preferable: 'less_than_recommended_volume'
          }
        }

        evaluation_hash = test_object.evaluate_target_dose_satisfied(
          conditional_skip: conditional_skip_object,
          antigen_series_dose: as_dose_object,
          preferable_intervals: [],
          allowable_intervals: [],
          antigen_series_dose_vaccines: as_dose_object.dose_vaccines,
          patient_dob: patient_dob,
          patient_gender: patient_gender,
          patient_vaccine_doses: patient_vaccines,
          dose_cvx: vaccine_dose.cvx_code,
          date_of_dose: vaccine_dose.date_administered,
          dose_volume: vaccine_dose.dosage,
          dose_trade_name: '',
          date_of_previous_dose: nil,
          previous_dose_status_hash: previous_status_hash
        )
        expect(evaluation_hash).to eq(expected_result)
      end
      it 'returns satisfied when the preferable vaccine volume is not given' do
        patient_vaccines     = test_patient.vaccine_doses
        vaccine_dose         = patient_vaccines[0]

        expect(vaccine_dose.dosage).to eq(nil)

        patient_dob          =
          (vaccine_dose.date_administered - 6.weeks)
        patient_gender       = test_patient.gender
        as_dose_object.absolute_min_age = '1 week'

        preferable_dose = as_dose_object.preferable_vaccines.find do |dose|
          dose.cvx_code == 10
        end

        expect(preferable_dose.volume).to eq('0.5')
        expect(preferable_dose.begin_age).to eq('6 weeks')

        previous_status_hash = nil
        expected_result = {
          evaluation_status: 'valid',
          target_dose_status: 'satisfied',
          details: {
            age: 'on_schedule',
            preferable_intervals: ['no_intervals_required'],
            allowable_intervals: ['no_intervals_required'],
            preferable: 'no_vaccine_dosage_provided'
          }
        }

        evaluation_hash = test_object.evaluate_target_dose_satisfied(
          conditional_skip: conditional_skip_object,
          antigen_series_dose: as_dose_object,
          preferable_intervals: [],
          allowable_intervals: [],
          antigen_series_dose_vaccines: as_dose_object.dose_vaccines,
          patient_dob: patient_dob,
          patient_gender: patient_gender,
          patient_vaccine_doses: patient_vaccines,
          dose_cvx: vaccine_dose.cvx_code,
          date_of_dose: vaccine_dose.date_administered,
          dose_volume: vaccine_dose.dosage,
          dose_trade_name: '',
          date_of_previous_dose: nil,
          previous_dose_status_hash: previous_status_hash
        )
        expect(evaluation_hash).to eq(expected_result)
      end
      it 'returns satisfied when the preferable vaccine is valid' do
        patient_vaccines     = test_patient.vaccine_doses
        vaccine_dose         = patient_vaccines[0]
        patient_dob          =
          (vaccine_dose.date_administered - 6.weeks)
        patient_gender       = test_patient.gender
        as_dose_object.absolute_min_age = '1 week'

        preferable_dose = as_dose_object.preferable_vaccines.find do |dose|
          dose.cvx_code == 10
        end
        expect(preferable_dose.begin_age).to eq('6 weeks')

        previous_status_hash = nil
        expected_result = {
          evaluation_status: 'valid',
          target_dose_status: 'satisfied',
          details: {
            age: 'on_schedule',
            preferable_intervals: ['no_intervals_required'],
            allowable_intervals: ['no_intervals_required'],
            preferable: 'within_age_trade_name_volume'
          }
        }

        evaluation_hash = test_object.evaluate_target_dose_satisfied(
          conditional_skip: conditional_skip_object,
          antigen_series_dose: as_dose_object,
          preferable_intervals: [],
          allowable_intervals: [],
          antigen_series_dose_vaccines: as_dose_object.dose_vaccines,
          patient_dob: patient_dob,
          patient_gender: patient_gender,
          patient_vaccine_doses: patient_vaccines,
          dose_cvx: vaccine_dose.cvx_code,
          date_of_dose: vaccine_dose.date_administered,
          dose_volume: '0.5',
          dose_trade_name: '',
          date_of_previous_dose: nil,
          previous_dose_status_hash: previous_status_hash
        )
        expect(evaluation_hash).to eq(expected_result)
      end
    end
    context 'when allowable vaccine is not_valid' do
      it 'ensures the vaccine codes are in cdc as_dose vaccine codes' do
        preferable_cvx_codes = as_dose_object.preferable_vaccines.map(&:cvx_code)
        allowable_cvx_codes  = as_dose_object.allowable_vaccines.map(&:cvx_code)
        test_patient.vaccine_doses.each do |vaccine_dose|
          expect(preferable_cvx_codes).to include(vaccine_dose.cvx_code)
          expect(allowable_cvx_codes).to include(vaccine_dose.cvx_code)
        end
      end
      it 'returns not_satisfied when the allowable vaccine is not_valid' do
        patient_vaccines     = test_patient.vaccine_doses
        vaccine_dose         = patient_vaccines[0]
        patient_dob          =
          (vaccine_dose.date_administered - 6.weeks + 5.days)
        patient_gender       = test_patient.gender
        as_dose_object.absolute_min_age = '1 week'

        preferable_dose = as_dose_object.preferable_vaccines.find do |dose|
          dose.cvx_code == 10
        end
        allowable_dose = as_dose_object.allowable_vaccines.find do |dose|
          dose.cvx_code == 10
        end
        expect(allowable_dose.begin_age).to eq('6 weeks - 4 days')
        expect(preferable_dose.begin_age).to eq('6 weeks')

        previous_status_hash = nil
        expected_result = {
          evaluation_status: 'not_valid',
          target_dose_status: 'not_satisfied',
          reason: 'allowable_vaccine_evaluation',
          details: {
            age: 'grace_period',
            preferable_intervals: ['no_intervals_required'],
            allowable_intervals: ['no_intervals_required'],
            allowable: 'out_of_age_range'
          }
        }

        evaluation_hash = test_object.evaluate_target_dose_satisfied(
          conditional_skip: conditional_skip_object,
          antigen_series_dose: as_dose_object,
          preferable_intervals: [],
          allowable_intervals: [],
          antigen_series_dose_vaccines: as_dose_object.dose_vaccines,
          patient_dob: patient_dob,
          patient_gender: patient_gender,
          patient_vaccine_doses: patient_vaccines,
          dose_cvx: vaccine_dose.cvx_code,
          date_of_dose: vaccine_dose.date_administered,
          dose_volume: vaccine_dose.dosage,
          dose_trade_name: '',
          date_of_previous_dose: nil,
          previous_dose_status_hash: previous_status_hash
        )
        expect(evaluation_hash).to eq(expected_result)
      end
      it 'returns satisfied when the allowable vaccine is valid' do
        patient_vaccines     = test_patient.vaccine_doses
        vaccine_dose         = patient_vaccines[0]
        patient_dob          =
          (vaccine_dose.date_administered - 6.weeks + 3.days)
        patient_gender       = test_patient.gender
        as_dose_object.absolute_min_age = '1 week'

        preferable_dose = as_dose_object.preferable_vaccines.find do |dose|
          dose.cvx_code == 10
        end
        allowable_dose = as_dose_object.allowable_vaccines.find do |dose|
          dose.cvx_code == 10
        end
        expect(allowable_dose.begin_age).to eq('6 weeks - 4 days')
        expect(preferable_dose.begin_age).to eq('6 weeks')

        previous_status_hash = nil
        expected_result = {
          evaluation_status: 'valid',
          target_dose_status: 'satisfied',
          details: {
            age: 'grace_period',
            preferable_intervals: ['no_intervals_required'],
            allowable_intervals: ['no_intervals_required'],
            allowable: 'within_age_range'
          }
        }

        evaluation_hash = test_object.evaluate_target_dose_satisfied(
          conditional_skip: conditional_skip_object,
          antigen_series_dose: as_dose_object,
          preferable_intervals: [],
          allowable_intervals: [],
          antigen_series_dose_vaccines: as_dose_object.dose_vaccines,
          patient_dob: patient_dob,
          patient_gender: patient_gender,
          patient_vaccine_doses: patient_vaccines,
          dose_cvx: vaccine_dose.cvx_code,
          date_of_dose: vaccine_dose.date_administered,
          dose_volume: vaccine_dose.dosage,
          dose_trade_name: '',
          date_of_previous_dose: nil,
          previous_dose_status_hash: previous_status_hash
        )
        expect(evaluation_hash).to eq(expected_result)
      end
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
