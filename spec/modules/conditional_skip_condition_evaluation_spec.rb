require 'rails_helper'

RSpec.describe ConditionalSkipConditionEvaluation do
  include PatientSpecHelper
  include AntigenImporterSpecHelper

  before(:all) { seed_antigen_xml_polio }
  after(:all) { DatabaseCleaner.clean_with(:truncation) }

  let(:test_object) do
    class TestClass
      include ConditionalSkipConditionEvaluation
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

  describe '#create_conditional_skip_condition_attributes' do
    it 'creates a begin_age_date attribute' do
      test_condition_object.begin_age = '3 years - 4 days'
      test_condition_object.condition_type = 'age'
      dob            = 5.years.ago.to_date
      expected_date  = dob + 3.years - 4.days
      prev_dose_date = 1.year.ago.to_date

      eval_hash =
        test_object.create_conditional_skip_condition_attributes(
          test_condition_object,
          prev_dose_date,
          dob
        )

      expect(eval_hash[:begin_age_date]).to eq(expected_date)
      expect(eval_hash[:condition_type]).to eq('age')
    end
    it 'creates a end_age_date attribute' do
      test_condition_object.end_age = '6 years'
      test_condition_object.condition_type = 'age'
      dob            = 10.years.ago.to_date
      expected_date  = dob + 6.years
      prev_dose_date = 7.year.ago.to_date

      eval_hash =
        test_object.create_conditional_skip_condition_attributes(
          test_condition_object,
          prev_dose_date,
          dob
        )

      expect(eval_hash[:end_age_date]).to eq(expected_date)
      expect(eval_hash[:condition_type]).to eq('age')
    end
    it 'creates a start_date attribute' do
      test_condition_object.start_date = '20150701'
      test_condition_object.condition_type = 'vaccine count by date'
      expected_date = Date.strptime('20150701', '%Y%m%d')

      eval_hash =
        test_object.create_conditional_skip_condition_attributes(
          test_condition_object,
          prev_dose_date,
          dob
        )

      expect(eval_hash[:start_date]).to eq(expected_date)
      expect(eval_hash[:condition_type]).to eq('vaccine count by date')
    end
    it 'creates a end_date attribute' do
      test_condition_object.end_date = '20160630'
      test_condition_object.condition_type = 'vaccine count by date'
      expected_date = Date.strptime('20160630', '%Y%m%d')

      eval_hash =
        test_object.create_conditional_skip_condition_attributes(
          test_condition_object,
          prev_dose_date,
          dob
        )

      expect(eval_hash[:end_date]).to eq(expected_date)
      expect(eval_hash[:condition_type]).to eq('vaccine count by date')
    end
    it 'creates a interval_date attribute when interval defined' do
      test_condition_object.interval = '6 months'
      test_condition_object.condition_type = 'Interval'
      expected_date = prev_dose_date + 6.months

      eval_hash =
        test_object.create_conditional_skip_condition_attributes(
          test_condition_object,
          prev_dose_date,
          dob
        )

      expect(eval_hash[:interval_date]).to eq(expected_date)
      expect(eval_hash[:condition_type]).to eq('Interval')
    end
    it 'raises error when previous_dose_date is nil and interval defined' do
      test_condition_object.interval = '6 months'
      test_condition_object.condition_type = 'Interval'
      prev_dose_date = nil

      expect{
        test_object.create_conditional_skip_condition_attributes(
          test_condition_object,
          prev_dose_date,
          dob
        )
      }.to raise_exception(ArgumentError)
    end
    it 'raises no error when previous_dose_date nil and no interval defined' do
      test_condition_object.interval = nil
      test_condition_object.end_date = '20160630'
      test_condition_object.condition_type = 'vaccine count by date'
      prev_dose_date = nil
      expected_date = Date.strptime('20160630', '%Y%m%d')

      eval_hash =
        test_object.create_conditional_skip_condition_attributes(
          test_condition_object,
          prev_dose_date,
          dob
        )
      expect(eval_hash[:end_date]).to eq(expected_date)
      expect(eval_hash[:condition_type]).to eq('vaccine count by date')
    end
    it 'creates an assessment_date attribute equal to current date' do
      expected_date = Date.today

      eval_hash =
        test_object.create_conditional_skip_condition_attributes(
          test_condition_object,
          prev_dose_date,
          dob
        )

      expect(eval_hash[:assessment_date]).to eq(expected_date)
    end
    it 'creates an condition_id and condition_type attribute' do
      expect(test_condition_object.condition_type).to eq('age')
      expect(test_condition_object.condition_id).to eq(1)

      eval_hash =
        test_object.create_conditional_skip_condition_attributes(
          test_condition_object,
          prev_dose_date,
          dob
        )

      expect(eval_hash[:condition_type]).to eq('age')
      expect(eval_hash[:condition_id]).to eq(1)
    end
    it 'creates dose_count attribute as an integer' do
      test_condition_object.dose_count = '5'

      eval_hash =
        test_object.create_conditional_skip_condition_attributes(
          test_condition_object,
          prev_dose_date,
          dob
        )
      expect(eval_hash[:dose_count]).to eq(5)
    end
    it 'creates dose_count attribute with nil for nil' do
      expect(test_condition_object.dose_count).to eq(nil)

      eval_hash =
        test_object.create_conditional_skip_condition_attributes(
          test_condition_object,
          prev_dose_date,
          dob
        )
      expect(eval_hash[:dose_count]).to eq(nil)
    end
    it 'creates dose_type attribute' do
      test_condition_object.dose_type = 'total'

      eval_hash =
        test_object.create_conditional_skip_condition_attributes(
          test_condition_object,
          prev_dose_date,
          dob
        )
      expect(eval_hash[:dose_type]).to eq('total')
    end
    it 'creates dose_count_logic attribute' do
      test_condition_object.dose_count_logic = 'greater than'

      eval_hash =
        test_object.create_conditional_skip_condition_attributes(
          test_condition_object,
          prev_dose_date,
          dob
        )
      expect(eval_hash[:dose_count_logic]).to eq('greater than')
    end
    it 'creates dose_type attribute as an array' do
      expected_result =
        '01;09;20;22;28;50;102;106;107;110;113;115;120;130;132;138;139;146'
        .split(';')
      test_condition_object.vaccine_types =
        '01;09;20;22;28;50;102;106;107;110;113;115;120;130;132;138;139;146'

      eval_hash =
        test_object.create_conditional_skip_condition_attributes(
          test_condition_object,
          prev_dose_date,
          dob
        )
      expect(eval_hash[:vaccine_types]).to eq(expected_result)
    end
    it 'creates dose_type attribute with a empty array value if nil' do
      test_condition_object.vaccine_types = nil

      eval_hash =
        test_object.create_conditional_skip_condition_attributes(
          test_condition_object,
          prev_dose_date,
          dob
        )
      expect(eval_hash[:vaccine_types]).to eq([])
    end
  end
  describe '#evaluate_conditional_skip_condition_attributes' do
    let(:valid_condition_attrs) do
      {
        begin_age_date: 10.months.ago.to_date,
        end_age_date: 2.months.ago.to_date,
        start_date: 10.months.ago.to_date,
        end_date: 2.months.ago.to_date,
        assessment_date: Date.today.to_date,
        condition_id: 1,
        condition_type: 'age',
        interval_date: 5.days.ago.to_date,
        dose_count: nil,
        dose_type: nil,
        dose_count_logic: nil,
        vaccine_types: []
      }
    end
    describe 'evaluating the conditional_type of completed series' do
      # TABLE 6-7 CONDITIONAL TYPE OF COMPLETED SERIES – IS THE CONDITION MET?
      it 'needs to be implemented' do
        expect(true).to eq(false)
      end
    end
    describe 'evaluating the interval_date attribute' do
      dose_date = 1.month.ago.to_date
      attribute_options = {
        before_the_dose_date: [2.months.ago.to_date, true],
        after_the_dose_date: [2.weeks.ago.to_date, false],
        nil: [nil, nil]
      }
      attribute_options.each do |descriptor, value|
        descriptor_string = "returns #{value[1]} when the interval_date"\
                            " attribute is #{descriptor}"
        it descriptor_string do
          valid_condition_attrs[:interval_date] = value[0]
          eval_hash =
            test_object
            .evaluate_conditional_skip_condition_attributes(
              valid_condition_attrs,
              dose_date
            )
          expect(eval_hash[:interval_date]).to eq(value[1])
        end
      end
    end
    describe 'evaluating the begin_age_date attribute' do
      dose_date = 9.months.ago.to_date
      attribute_options = {
        before_the_dose_date: [10.months.ago.to_date, true],
        after_the_dose_date: [8.months.ago.to_date, false],
        nil: [nil, nil]
      }
      attribute_options.each do |descriptor, value|
        descriptor_string = "returns #{value[1]} when the begin_age_date"\
                            " attribute is #{descriptor}"
        it descriptor_string do
          valid_condition_attrs[:begin_age_date] = value[0]
          eval_hash =
            test_object
            .evaluate_conditional_skip_condition_attributes(
              valid_condition_attrs,
              dose_date
            )
          expect(eval_hash[:begin_age]).to eq(value[1])
        end
      end
    end
    describe 'evaluating the end_age_date attribute' do
      dose_date = 9.months.ago.to_date
      attribute_options = {
        before_the_dose_date: [10.months.ago.to_date, false],
        after_the_dose_date: [8.months.ago.to_date, true],
        nil: [nil, nil]
      }
      attribute_options.each do |descriptor, value|
        descriptor_string = "returns #{value[1]} when the end_age_date"\
                            " attribute is #{descriptor}"
        it descriptor_string do
          valid_condition_attrs[:end_age_date] = value[0]
          eval_hash =
            test_object
            .evaluate_conditional_skip_condition_attributes(
              valid_condition_attrs,
              dose_date
            )
          expect(eval_hash[:end_age]).to eq(value[1])
        end
      end
    end
    describe 'evaluating the start_date attribute' do
      dose_date = 9.months.ago.to_date
      attribute_options = {
        before_the_dose_date: [10.months.ago.to_date, true],
        after_the_dose_date: [8.months.ago.to_date, false],
        nil: [nil, nil]
      }
      attribute_options.each do |descriptor, value|
        descriptor_string = "returns #{value[1]} when the start_date"\
                            " attribute is #{descriptor}"
        it descriptor_string do
          valid_condition_attrs[:start_date] = value[0]
          eval_hash =
            test_object
            .evaluate_conditional_skip_condition_attributes(
              valid_condition_attrs,
              dose_date
            )
          expect(eval_hash[:start_date]).to eq(value[1])
        end
      end
    end
    describe 'evaluating the end_date attribute' do
      dose_date = 9.months.ago.to_date
      attribute_options = {
        before_the_dose_date: [10.months.ago.to_date, false],
        after_the_dose_date: [8.months.ago.to_date, true],
        nil: [nil, nil]
      }
      attribute_options.each do |descriptor, value|
        descriptor_string = "returns #{value[1]} when the end_date"\
                            " attribute is #{descriptor}"
        it descriptor_string do
          valid_condition_attrs[:end_date] = value[0]
          eval_hash =
            test_object
            .evaluate_conditional_skip_condition_attributes(
              valid_condition_attrs,
              dose_date
            )
          expect(eval_hash[:end_date]).to eq(value[1])
        end
      end
    end
    describe 'evaluating the dose_count attributes' do
      let(:test_patient_no_vaccines) do
        FactoryGirl.create(:patient_with_profile)
      end
      let(:valid_antigen_administered_records) do
        valid_dose_dates =
          [2.years.ago, 1.year.ago, 6.months.ago, 5.months.ago, 4.months.ago]
        create_antigen_administered_records(test_patient_no_vaccines,
                                            valid_dose_dates,
                                            10)
      end

      context 'conditional_type "vaccine count by age"' do
        let(:valid_dose_count_by_age_attributes) do
          {
            begin_age_date: (test_patient_no_vaccines.dob + 6.weeks),
            end_age_date: nil,
            start_date: nil,
            end_date: nil,
            assessment_date: Date.today.to_date,
            condition_id: 1,
            condition_type: 'vaccine count by age',
            interval_date: nil,
            dose_count: 4,
            dose_type: 'total',
            dose_count_logic: 'greater than',
            vaccine_types: [1, 10, 20, 22, 28, 50, 102, 106, 107, 110, 113,
                            115, 120, 130, 132, 138, 139, 146]
          }
        end
        it 'returns true if the actual count is greater than required' do
          # aars are subbing for valid TargetDoses in this case
          aars         = valid_antigen_administered_records
          test_patient = test_patient_no_vaccines
          dose_date    = 3.months.ago
          eval_hash =
            test_object.evaluate_conditional_skip_condition_attributes(
              valid_dose_count_by_age_attributes,
              dose_date,
              satisfied_target_doses: aars,
              patient_vaccine_doses: test_patient.vaccine_doses
            )

          expect(eval_hash[:dose_count_valid]).to eq(true)
        end
        it 'returns false if the actual count is less than required' do
          valid_dose_count_by_age_attributes[:dose_count] = 100
          # aars are subbing for valid TargetDoses in this case
          aars         = valid_antigen_administered_records
          test_patient = test_patient_no_vaccines
          dose_date    = 3.months.ago

          eval_hash =
            test_object.evaluate_conditional_skip_condition_attributes(
              valid_dose_count_by_age_attributes,
              dose_date,
              satisfied_target_doses: aars,
              patient_vaccine_doses: test_patient.vaccine_doses
            )

          expect(eval_hash[:dose_count_valid]).to eq(false)
        end
        it 'evaluates the vaccine_doses if dose_type is total' do
          # aars are subbing for valid TargetDoses in this case
          valid_dose_count_by_age_attributes[:dose_type] = 'total'
          valid_antigen_administered_records
          test_patient = test_patient_no_vaccines
          dose_date    = 3.months.ago

          expect(test_patient.vaccine_doses.length).not_to eq(0)

          eval_hash =
            test_object.evaluate_conditional_skip_condition_attributes(
              valid_dose_count_by_age_attributes,
              dose_date,
              satisfied_target_doses: [],
              patient_vaccine_doses: test_patient.vaccine_doses
            )

          expect(eval_hash[:dose_count_valid]).to eq(true)
        end
        it 'evaluates the satisfied_target_doses if dose_type is valid' do
          # aars are subbing for valid TargetDoses in this case
          valid_dose_count_by_age_attributes[:dose_type] = 'valid'
          aars      = valid_antigen_administered_records
          dose_date = 3.months.ago

          expect(test_patient.vaccine_doses.length).not_to eq(0)

          eval_hash =
            test_object.evaluate_conditional_skip_condition_attributes(
              valid_dose_count_by_age_attributes,
              dose_date,
              satisfied_target_doses: aars,
              patient_vaccine_doses: []
            )
          expect(eval_hash[:dose_count_valid]).to eq(true)
        end
      end
      context 'conditional_type "vaccine count by date"' do
        let(:valid_dose_count_by_date_attributes) do
          {
            begin_age_date: nil,
            end_age_date: nil,
            start_date: 2.years.ago,
            end_date: 1.day.ago,
            assessment_date: Date.today.to_date,
            condition_id: 1,
            condition_type: 'vaccine count by date',
            interval_date: nil,
            dose_count: 0,
            dose_type: 'valid',
            dose_count_logic: 'greater than',
            vaccine_types: [1, 10, 20, 22, 28, 50, 102, 106, 107, 110, 113,
                            115, 120, 130, 132, 138, 139, 146]
          }
        end
        it 'returns true if the actual count is greater than required' do
          # aars are subbing for valid TargetDoses in this case
          test_patient = test_patient_no_vaccines
          dose_date    = 3.months.ago
          aars = create_antigen_administered_records(test_patient_no_vaccines,
                                                     [1.year.ago],
                                                     10)

          expect(test_patient.vaccine_doses.length).to eq(1)

          eval_hash =
            test_object.evaluate_conditional_skip_condition_attributes(
              valid_dose_count_by_date_attributes,
              dose_date,
              satisfied_target_doses: aars,
              patient_vaccine_doses: test_patient.vaccine_doses
            )

          expect(eval_hash[:dose_count_valid]).to eq(true)
        end
        it 'returns false if the actual count is less than required' do
          # This is also checking for when it was given, which is outside
          # of the range required.
          # aars are subbing for valid TargetDoses in this case
          test_patient = test_patient_no_vaccines
          dose_date    = 3.months.ago
          aars = create_antigen_administered_records(test_patient_no_vaccines,
                                                     [3.years.ago],
                                                     10)

          expect(test_patient.vaccine_doses.length).to eq(1)

          eval_hash =
            test_object.evaluate_conditional_skip_condition_attributes(
              valid_dose_count_by_date_attributes,
              dose_date,
              satisfied_target_doses: aars,
              patient_vaccine_doses: test_patient.vaccine_doses
            )

          expect(eval_hash[:dose_count_valid]).to eq(false)
        end
        it 'evaluates the vaccine_doses if dose_type is total' do
          # aars are subbing for valid TargetDoses in this case
          valid_dose_count_by_date_attributes[:dose_type] = 'total'
          test_patient = test_patient_no_vaccines
          dose_date    = 3.months.ago
          create_antigen_administered_records(test_patient_no_vaccines,
                                              [1.year.ago],
                                              10)

          expect(test_patient.vaccine_doses.length).to eq(1)

          eval_hash =
            test_object.evaluate_conditional_skip_condition_attributes(
              valid_dose_count_by_date_attributes,
              dose_date,
              satisfied_target_doses: [],
              patient_vaccine_doses: test_patient.vaccine_doses
            )

          expect(eval_hash[:dose_count_valid]).to eq(true)
        end
        it 'evaluates the satisfied_target_doses if dose_type is valid' do
          # aars are subbing for valid TargetDoses in this case
          valid_dose_count_by_date_attributes[:dose_type] = 'valid'
          test_patient = test_patient_no_vaccines
          dose_date    = 3.months.ago
          aars = create_antigen_administered_records(test_patient_no_vaccines,
                                                     [1.year.ago],
                                                     10)

          expect(test_patient.vaccine_doses.length).to eq(1)

          eval_hash =
            test_object.evaluate_conditional_skip_condition_attributes(
              valid_dose_count_by_date_attributes,
              dose_date,
              satisfied_target_doses: aars,
              patient_vaccine_doses: []
            )
          expect(eval_hash[:dose_count_valid]).to eq(true)
        end
      end
    end
  end
  describe '#get_conditional_skip_condition_status' do
    # This logic is defined on page 50 of the CDC logic spec
    let(:eval_hash) do
      { begin_age: nil,
        start_date: nil,
        end_age: nil,
        end_date: nil,
        interval_date: nil }
    end

    [
      ['begin_age', true, 'condition_met', 'age'],
      ['begin_age', false, 'condition_not_met', 'age'],
      ['end_age', true, 'condition_met', 'age'],
      ['end_age', false, 'condition_not_met', 'age'],
      ['start_date', true, 'condition_met', 'dose_timing'],
      ['start_date', false, 'condition_not_met', 'dose_timing'],
      ['end_date', true, 'condition_met', 'dose_timing'],
      ['end_date', false, 'condition_not_met', 'dose_timing'],
      ['interval_date', true, 'condition_met', 'interval'],
      ['interval_date', false, 'condition_not_met', 'interval']
    ].each do |test_array|
      input_key, input_value, expected_status, expected_reason = test_array
      evaluated = 'conditional_skip_condition'

      it "returns evaluation_status: #{expected_status}, reason: #{expected_reason}, " \
         "evaluated: #{evaluated} for #{input_key}: #{input_value}" do
         eval_hash[input_key.to_sym] = input_value

         status_hash = test_object.get_conditional_skip_condition_status(
           eval_hash
         )
         expect(status_hash[:evaluation_status]).to eq(expected_status)
         expect(status_hash[:reason]).to eq(expected_reason)
         expect(status_hash[:evaluated]).to eq(evaluated)
      end
    end
  end
  describe '#evaluate_conditional_skip_condition ' do
    it 'takes a condition with condition, patient_dob, date_of_dose, ' \
    'patient_vaccine_doses, date_of_previous_dose and returns a status hash' do
      condition_object = condition1a
      patient_dob      = test_patient.dob
      vaccine_doses    = test_patient.vaccine_doses
      vaccine_dose     = vaccine_doses.first
      date_of_dose     = vaccine_dose.date_administered
      evaluation_hash = test_object.evaluate_conditional_skip_condition(
        condition_object,
        patient_dob: patient_dob,
        date_of_dose: date_of_dose,
        patient_vaccine_doses: vaccine_doses
      )
      expected_result = {
        evaluated: 'conditional_skip_condition',
        reason: 'age',
        evaluation_status: 'condition_met'
      }
      expect(evaluation_hash).to eq(expected_result)
    end
  end
end
