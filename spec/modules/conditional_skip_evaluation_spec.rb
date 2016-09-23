require 'rails_helper'
require 'conditional_skip_evaluation'

RSpec.describe ConditionalSkipEvaluation do
  include PatientSpecHelper
  include AntigenImporterSpecHelper

  before(:all) { seed_antigen_xml_polio }
  after(:all) { DatabaseCleaner.clean_with(:truncation) }

  let(:test_object) do
    class TestClass
      include ConditionalSkipEvaluation
    end
    TestClass.new
  end

  let(:condition1a) do
    FactoryGirl.create(
      :conditional_skip_condition,
      **{
          condition_id: 1,
          condition_type: 'age',
          start_date: '',
          end_date: '',
          begin_age: '4 years - 4 days',
          end_age: '',
          interval: '',
          dose_count: '',
          dose_type: '',
          dose_count_logic: '',
          vaccine_types: ''
        }
    )
  end
  let(:condition2a) do
    FactoryGirl.create(
      :conditional_skip_condition,
      **{
          condition_id: 2,
          condition_type: 'age',
          start_date: '',
          end_date: '',
          begin_age: '',
          end_age: '',
          interval: '6 months - 4 days',
          dose_count: '',
          dose_type: '',
          dose_count_logic: '',
          vaccine_types: ''
        }
    )
  end
  let(:conditional_set1a) do
    FactoryGirl.create(
      :conditional_skip_set,
      **{
          set_id: 1,
          set_description: 'Dose is not required for those 4 years or older' \
            'when the interval from the last dose is 6 months',
          condition_logic: 'and',
          conditions: [condition1a, condition2a]
        }
    )
  end
  let(:conditional_skip_object) do
    FactoryGirl.create(:conditional_skip,
                       set_logic: 'n/a',
                       sets: [conditional_set1a])
  end

  let(:test_condition_object) do
    FactoryGirl.create(:conditional_skip_condition)
  end

  let(:test_patient) do
    test_patient = FactoryGirl.create(:patient_with_profile)
    # These vaccines are will evaluate to valid dose to skip as it is past
    # 4 years and the interval is more than 6 months as noted in
    # conditional_skip_set set_description
    FactoryGirl.create(
      :vaccine_dose,
      patient_profile: test_patient.patient_profile,
      vaccine_code: 'IPV',
      date_administered: (test_patient.dob + 5.years)
    )
    FactoryGirl.create(
      :vaccine_dose,
      patient_profile: test_patient.patient_profile,
      vaccine_code: 'IPV',
      date_administered: (test_patient.dob + 6.years)
    )
    test_patient.reload
    test_patient
  end

  let(:dob) { 10.years.ago.to_date }
  let(:prev_dose_date) { 4.months.ago.to_date }

  # describe '#number_of_conditional_doses_administered' do
  #   it 'evaluates the number of vaccine doses administered that meet all'\
  #     'requirements' do
  #       # Vaccine Type is one of the supporting data defined conditional
  #       #   skip vaccine types
  #   end
  # end
  describe '#get_conditional_skip_set_status ' do
    condition_statuses = {
      all_met:  [{evaluation_status: 'condition_met', reason: 'age'},
                 {evaluation_status: 'condition_met', reason: 'interval'}],
      one_met:  [{evaluation_status: 'condition_met', reason: 'age'},
                 {evaluation_status: 'condition_not_met', reason: 'interval'}],
      none_met: [{evaluation_status: 'condition_not_met', reason: 'age'},
                 {evaluation_status: 'condition_not_met', reason: 'interval'}]
    }

    {
      and: [['all_met', 'set_met'],
            ['one_met', 'set_not_met'],
            ['none_met', 'set_not_met']
           ],
      or: [['all_met', 'set_met'],
           ['one_met', 'set_met'],
           ['none_met', 'set_not_met']
          ]
    }.each do |condition_logic, value_arrays|
      value_arrays.each do |value_array|
        expected_status    = value_array[1]
        statuses_key       = value_array[0]
        statuses = condition_statuses[statuses_key.to_sym]
        it "takes condition_logic #{condition_logic} with condition statuses" \
           " with #{statuses_key} and returns evaluation_status: #{expected_status}" do
          result_hash = test_object.get_conditional_skip_set_status(
            condition_logic.to_s,
            statuses
          )
          expect(result_hash[:evaluation_status]).to eq(expected_status)
          expect(result_hash[:evaluated]).to eq('conditional_skip_set')
          if statuses_key == 'all_met'
            expect(result_hash[:met_conditions])
              .to eq(condition_statuses[:all_met])
            expect(result_hash[:not_met_conditions])
              .to eq([])
          elsif statuses_key == 'none_met'
            expect(result_hash[:met_conditions])
              .to eq([])
            expect(result_hash[:not_met_conditions])
              .to eq(condition_statuses[:none_met])
          else
            expect(result_hash[:met_conditions])
              .to eq([condition_statuses[:one_met][0]])
            expect(result_hash[:not_met_conditions])
              .to eq([condition_statuses[:one_met][1]])
          end
        end
      end
    end

    it 'raises an error if the condition_statuses_array is empty' do
      expect{
        test_object.get_conditional_skip_set_status('and', [])
      }.to raise_exception(ArgumentError)
    end
  end
  describe '#get_conditional_skip_status ' do
    set_statuses_hash = {
      all_met:  [{evaluation_status: 'set_met'}, {evaluation_status: 'set_met'}],
      one_met:  [{evaluation_status: 'set_met'}, {evaluation_status: 'set_not_met'}],
      none_met: [{evaluation_status: 'set_not_met'}, {evaluation_status: 'set_not_met'}]
    }

    {
      and: [['all_met', 'conditional_skip_met'],
            ['one_met', 'conditional_skip_not_met'],
            ['none_met', 'conditional_skip_not_met']
           ],
      or: [['all_met', 'conditional_skip_met'],
           ['one_met', 'conditional_skip_met'],
           ['none_met', 'conditional_skip_not_met']
          ]
    }.each do |set_logic, value_arrays|
      value_arrays.each do |value_array|
        expected_status    = value_array[1]
        statuses_key       = value_array[0]
        condition_statuses = set_statuses_hash[statuses_key.to_sym]
        it "takes condition_logic #{set_logic} with condition statuses " \
           "with #{statuses_key} and returns evaluation_status: #{expected_status}" do
          result_hash = test_object.get_conditional_skip_status(
            set_logic.to_s,
            condition_statuses
          )
          expect(result_hash[:evaluation_status]).to eq(expected_status)
          expect(result_hash[:evaluated]).to eq('conditional_skip')
        end
      end
    end

    it 'raises an error if the condition_statuses_array is empty' do
      expect{
        test_object.get_conditional_skip_status('and', [])
      }.to raise_exception(ArgumentError)
    end
  end
  describe '#evaluate_conditional_skip_set ' do
    it 'takes a set_object, with a patient_dob, patient_vaccine_doses, ' \
        'date_of_dose and returns a status hash' do
      set_object         = conditional_set1a
      patient_dob        = test_patient.dob
      vaccine_doses      = test_patient.vaccine_doses
      vaccine_dose       = vaccine_doses.last
      date_of_dose       = vaccine_dose.date_administered
      fake_target_doses  =
        create_fake_valid_target_doses(vaccine_doses[0..-2])
      evaluation_hash    = test_object.evaluate_conditional_skip_set(
        set_object,
        patient_dob: patient_dob,
        date_of_dose: date_of_dose,
        patient_vaccine_doses: vaccine_doses,
        satisfied_target_doses: fake_target_doses
      )
      expected_result = {
        evaluated: 'conditional_skip_set',
        met_conditions: [
          {
            evaluated: 'conditional_skip_condition',
            evaluation_status: 'condition_met',
            reason: 'age'
          },
          {
            evaluated: 'conditional_skip_condition',
            evaluation_status: 'condition_met',
            reason: 'interval'
          },
        ],
        not_met_conditions: [],
        evaluation_status: 'set_met'
      }
      expect(evaluation_hash).to eq(expected_result)
    end
    it 'returns conditions_met and conditions_not_met arrays' do
      set_object         = conditional_set1a
      patient_dob        = 3.years.ago.to_date
      vaccine_doses      = test_patient.vaccine_doses
      vaccine_dose       = vaccine_doses.last
      date_of_dose       = vaccine_dose.date_administered
      fake_target_doses  =
        create_fake_valid_target_doses(vaccine_doses[0..-2])
      evaluation_hash    = test_object.evaluate_conditional_skip_set(
        set_object,
        patient_dob: patient_dob,
        date_of_dose: date_of_dose,
        patient_vaccine_doses: vaccine_doses,
        satisfied_target_doses: fake_target_doses
      )
      expected_result = {
        evaluated: 'conditional_skip_set',
        met_conditions: [
          {
            evaluated: "conditional_skip_condition",
            evaluation_status: "condition_met",
            reason: "interval"
          }
        ],
        not_met_conditions: [
          {
            evaluated: "conditional_skip_condition",
            evaluation_status: "condition_not_met",
            reason: "age"
          }
        ],
        evaluation_status: 'set_not_met'
      }
      expect(evaluation_hash).to eq(expected_result)
    end
  end
  describe '#evaluate_conditional_skip ' do
    it 'takes a conditional_skip_object with date_of_dose, patient_dob, ' \
       'patient_vaccine_doses and returns a status hash' do
      patient_dob             = test_patient.dob
      vaccine_doses           = test_patient.vaccine_doses
      vaccine_dose            = vaccine_doses.last
      date_of_dose            = vaccine_dose.date_administered
      fake_target_doses       =
        create_fake_valid_target_doses(vaccine_doses[0..-2])
      evaluation_hash = test_object.evaluate_conditional_skip(
        conditional_skip_object,
        patient_dob: patient_dob,
        date_of_dose: date_of_dose,
        patient_vaccine_doses: vaccine_doses,
        satisfied_target_doses: fake_target_doses
      )
      expected_result = {
        evaluated: 'conditional_skip',
        met_sets: [
          {
            evaluated: 'conditional_skip_set',
            met_conditions: [
              {
                evaluated: 'conditional_skip_condition',
                evaluation_status: 'condition_met',
                reason: 'age'
              },
              {
                evaluated: 'conditional_skip_condition',
                evaluation_status: 'condition_met',
                reason: 'interval'
              }
            ],
            not_met_conditions: [],
            evaluation_status: 'set_met'
          }
        ],
        not_met_sets: [],
        evaluation_status: 'conditional_skip_met'
      }
      expect(evaluation_hash).to eq(expected_result)
    end
    it 'returns sets_met_and sets_not_met arrays' do
      patient_dob             = 3.years.ago.to_date
      vaccine_doses           = test_patient.vaccine_doses
      vaccine_dose            = vaccine_doses.last
      date_of_dose            = vaccine_dose.date_administered
      fake_target_doses       =
        create_fake_valid_target_doses(vaccine_doses[0..-2])
      evaluation_hash = test_object.evaluate_conditional_skip(
        conditional_skip_object,
        patient_dob: patient_dob,
        date_of_dose: date_of_dose,
        patient_vaccine_doses: vaccine_doses,
        satisfied_target_doses: fake_target_doses
      )
      expected_result = {
        evaluated: 'conditional_skip',
        met_sets: [],
        not_met_sets: [
          {
            evaluated: 'conditional_skip_set',
            met_conditions: [
              {
                evaluated: 'conditional_skip_condition',
                evaluation_status: 'condition_met',
                reason: 'interval'
              }
            ],
            not_met_conditions: [
              {
                evaluated: 'conditional_skip_condition',
                evaluation_status: 'condition_not_met',
                reason: 'age'
              }
            ],
            evaluation_status: 'set_not_met'
          }
        ],
        evaluation_status: 'conditional_skip_not_met'
      }
      expect(evaluation_hash).to eq(expected_result)
    end
  end
end
