require 'rails_helper'
require 'conditional_skip_evaluation'

RSpec.describe ConditionalSkipEvaluation do
  let(:test_object) do
    class TestClass
      include ConditionalSkipEvaluation
    end
    TestClass.new
  end

  let(:condition1) do
    FactoryGirl.create(:conditional_skip_set_condition,
      **{
          condition_id: 1,
          condition_type: 'Age',
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
  let(:condition2) do
    FactoryGirl.create(:conditional_skip_set_condition,
      **{
          condition_id: 2,
          condition_type: 'Age',
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
  let(:conditional_set1) do
    FactoryGirl.create(:conditional_skip_set,
      **{
          set_id: 1,
          set_description: 'Dose is not required for those 4 years or older' \
            'when the interval from the last dose is 6 months',
          condition_logic: 'AND',
          conditions: [condition1, condition2]
        }
    )
  end
  let(:conditional_skip_object) do
    FactoryGirl.create(:conditional_skip_set,
                       set_logic: 'n/a',
                       sets: [conditional_set1])
  end

  let(:test_condition_object) do
    FactoryGirl.create(:conditional_skip_set_condition)
  end

  let(:test_patient) do
    test_patient = FactoryGirl.create(:patient)
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

  # describe '#create_conditional_skip_attributes' do
  #   # test_condition_object,
  #   # prev_dose_date,
  #   # later_dose_date,
  #   # dob

  #   it 'creates an array of set_attributes' do
  #     condition_attrs = []
  #     condition_attrs <<
  #       test_object.create_conditional_skip_set_condition_attributes(
  #         condition1,
  #         prev_dose_date,
  #         dob
  #       )
  #     condition_attrs <<
  #       test_object.create_conditional_skip_set_condition_attributes(
  #         condition2,
  #         prev_dose_date,
  #         dob
  #       )

  #     eval_hash =
  #       test_object.create_conditional_skip_set_condition_attributes(
  #         test_condition_object,
  #         prev_dose_date,
  #         dob
  #       )

  #     expect(eval_hash[:begin_age_date]).to eq(expected_date)
  #     expect(eval_hash[:condition_type]).to eq('Age')
  #   end
  # end

  describe '#create_conditional_skip_set_condition_attributes' do
    it 'creates a begin_age_date attribute' do
      test_condition_object.begin_age = '3 years - 4 days'
      test_condition_object.condition_type = 'Age'
      dob            = 5.years.ago.to_date
      expected_date  = dob + 3.years - 4.days
      prev_dose_date = 1.year.ago.to_date

      eval_hash =
        test_object.create_conditional_skip_set_condition_attributes(
          test_condition_object,
          prev_dose_date,
          dob
        )

      expect(eval_hash[:begin_age_date]).to eq(expected_date)
      expect(eval_hash[:condition_type]).to eq('Age')
    end
    it 'creates a end_age_date attribute' do
      test_condition_object.end_age = '6 years'
      test_condition_object.condition_type = 'Age'
      dob            = 10.years.ago.to_date
      expected_date  = dob + 6.years
      prev_dose_date = 7.year.ago.to_date

      eval_hash =
        test_object.create_conditional_skip_set_condition_attributes(
          test_condition_object,
          prev_dose_date,
          dob
        )

      expect(eval_hash[:end_age_date]).to eq(expected_date)
      expect(eval_hash[:condition_type]).to eq('Age')
    end
    it 'creates a start_date attribute' do
      test_condition_object.start_date = '20150701'
      test_condition_object.condition_type = 'Vaccine Count by Date'
      expected_date = Date.strptime('20150701', '%Y%m%d')

      eval_hash =
        test_object.create_conditional_skip_set_condition_attributes(
          test_condition_object,
          prev_dose_date,
          dob
        )

      expect(eval_hash[:start_date]).to eq(expected_date)
      expect(eval_hash[:condition_type]).to eq('Vaccine Count by Date')
    end
    it 'creates a end_date attribute' do
      test_condition_object.end_date = '20160630'
      test_condition_object.condition_type = 'Vaccine Count by Date'
      expected_date = Date.strptime('20160630', '%Y%m%d')

      eval_hash =
        test_object.create_conditional_skip_set_condition_attributes(
          test_condition_object,
          prev_dose_date,
          dob
        )

      expect(eval_hash[:end_date]).to eq(expected_date)
      expect(eval_hash[:condition_type]).to eq('Vaccine Count by Date')
    end
    it 'creates an assessment_date attribute equal to current date' do
      expected_date = Date.today

      eval_hash =
        test_object.create_conditional_skip_set_condition_attributes(
          test_condition_object,
          prev_dose_date,
          dob
        )

      expect(eval_hash[:assessment_date]).to eq(expected_date)
    end
    it 'creates an condition_id and condition_type attribute' do
      expect(test_condition_object.condition_type).to eq('Age')
      expect(test_condition_object.condition_id).to eq(1)

      eval_hash =
        test_object.create_conditional_skip_set_condition_attributes(
          test_condition_object,
          prev_dose_date,
          dob
        )

      expect(eval_hash[:condition_type]).to eq('Age')
      expect(eval_hash[:condition_id]).to eq(1)
    end
    it 'creates dose_count attribute as an integer' do
      test_condition_object.dose_count = '5'

      eval_hash =
        test_object.create_conditional_skip_set_condition_attributes(
          test_condition_object,
          prev_dose_date,
          dob
        )
      expect(eval_hash[:dose_count]).to eq(5)
    end
    it 'creates dose_count attribute with nil for nil' do
      expect(test_condition_object.dose_count).to eq(nil)

      eval_hash =
        test_object.create_conditional_skip_set_condition_attributes(
          test_condition_object,
          prev_dose_date,
          dob
        )
      expect(eval_hash[:dose_count]).to eq(nil)
    end
    it 'creates dose_type attribute' do
      test_condition_object.dose_type = 'Total'

      eval_hash =
        test_object.create_conditional_skip_set_condition_attributes(
          test_condition_object,
          prev_dose_date,
          dob
        )
      expect(eval_hash[:dose_type]).to eq('Total')
    end
    it 'creates dose_count_logic attribute' do
      test_condition_object.dose_count_logic = 'greater than'

      eval_hash =
        test_object.create_conditional_skip_set_condition_attributes(
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
        test_object.create_conditional_skip_set_condition_attributes(
          test_condition_object,
          prev_dose_date,
          dob
        )
      expect(eval_hash[:vaccine_types]).to eq(expected_result)
    end
    it 'creates dose_type attribute with a empty array value if nil' do
      test_condition_object.vaccine_types = nil

      eval_hash =
        test_object.create_conditional_skip_set_condition_attributes(
          test_condition_object,
          prev_dose_date,
          dob
        )
      expect(eval_hash[:vaccine_types]).to eq([])
    end
  end
  # describe '#number_of_conditional_doses_administered' do
  #   it 'evaluates the number of vaccine doses administered that meet all'\
  #     'requirements' do
  #       # Vaccine Type is one of the supporting data defined conditional
  #       #   skip vaccine types
  #   end
  # end
  describe '#match_vaccine_doses_with_cvx_codes' do
    let(:cvx_polio) { [10, 110, 120] }
    let(:cvx_non_polio) { [162, 133, 85] }
    let(:all_vaccine_doses) do
      cvx_codes = [cvx_polio, cvx_non_polio].flatten
      vaccine_doses = []
      cvx_codes.each_with_index do |cvx_code, index|
        vax_code = TextVax.find_all_vax_codes_by_cvx(cvx_code).first
        vaccine_doses << FactoryGirl.create_list(
          :vaccine_dose,
          (index + 1),
          vaccine_code: vax_code,
          patient_profile: test_patient.patient_profile
        )
      end
      vaccine_doses.flatten
    end
    it 'pulls all vaccine_doses that match the cvx_codes' do
      polio_vaccine_doses =
        test_object.match_vaccine_doses_with_cvx_codes(
          all_vaccine_doses,
          cvx_polio
        )
      expect(polio_vaccine_doses.length).to eq(6)
      expect(polio_vaccine_doses.first.class.name).to eq('VaccineDose')
    end
    it 'returns an empty array if the cvx_codes is empty' do
      polio_vaccine_doses =
        test_object.match_vaccine_doses_with_cvx_codes(
          all_vaccine_doses,
          []
        )
      expect(polio_vaccine_doses.length).to eq(0)
    end
    it 'returns an empty array if there are no vaccines that match' do
      polio_vaccine_doses =
        test_object.match_vaccine_doses_with_cvx_codes(
          all_vaccine_doses,
          [12, 13, 14, 15]
        )
      expect(polio_vaccine_doses.length).to eq(0)
    end
  end
  describe '#calculate_count_of_vaccine_doses' do
    let(:cvx_polio) { [10, 110, 120] }
    let(:cvx_non_polio) { [162, 133, 85] }
    let(:valid_vaccine_types) do
      [1, 10, 22, 50, 102, 106, 107, 110, 115, 120, 130, 132, 146]
    end
    let(:test_condition_object) do
      FactoryGirl.create(
        :conditional_skip_set_condition,
        begin_age: '3 years - 4 days',
        condition_type: 'Age',
        dose_type: 'Valid',
        vaccine_types: valid_vaccine_types.join(';')
      )
    end
    let(:all_vaccine_doses) do
      cvx_codes = [cvx_polio, cvx_non_polio].flatten
      vaccine_doses = []
      cvx_codes.each_with_index do |cvx_code, index|
        vax_code = TextVax.find_all_vax_codes_by_cvx(cvx_code).first
        vaccine_doses << FactoryGirl.create_list(
          :vaccine_dose,
          (index + 1),
          vaccine_code: vax_code,
          patient_profile: test_patient.patient_profile
        )
      end
      vaccine_doses.flatten
    end

    it 'it includes only vaccines from the list of vaccine types' do
      expect(all_vaccine_doses.length).to eq(21)
      same_vaccine_types = all_vaccine_doses.select do |vaccine_dose|
        valid_vaccine_types.include?(vaccine_dose.cvx_code)
      end
      expect(same_vaccine_types.length).to eq(6)
      expect(
        test_object.calculate_count_of_vaccine_doses(
          all_vaccine_doses,
          test_condition_object.vaccine_types
        )
      ).to eq(6)
    end

    it 'it includes only vaccines given after the begin_age' do
      expect(test_condition_object.begin_age).to eq('3 years - 4 days')
      patient = all_vaccine_doses.first.patient
      begin_age_date = patient.dob + 3.years - 4.days
      test_vaccine_doses = [FactoryGirl.create(
        :vaccine_dose_by_cvx,
        patient_profile: patient.patient_profile,
        cvx_code: 10,
        date_administered: (patient.dob + 4.years)
      )]
      test_vaccine_doses << FactoryGirl.create(
        :vaccine_dose_by_cvx,
        patient_profile: patient.patient_profile,
        cvx_code: 10,
        date_administered: (patient.dob + 2.years)
      )
      expect(
        test_object.calculate_count_of_vaccine_doses(
          test_vaccine_doses,
          test_condition_object.vaccine_types,
          begin_age_date: begin_age_date
        )
      ).to eq(1)
    end

    it 'it includes only vaccines given before the end_age' do
      patient = all_vaccine_doses.first.patient
      end_age_date = patient.dob + 4.years
      test_vaccine_doses = [FactoryGirl.create(
        :vaccine_dose_by_cvx,
        patient_profile: patient.patient_profile,
        cvx_code: 10,
        date_administered: (patient.dob + 5.years)
      )]
      test_vaccine_doses << FactoryGirl.create(
        :vaccine_dose_by_cvx,
        patient_profile: patient.patient_profile,
        cvx_code: 10,
        date_administered: (patient.dob + 2.years)
      )
      test_vaccine_doses << FactoryGirl.create(
        :vaccine_dose_by_cvx,
        patient_profile: patient.patient_profile,
        cvx_code: 10,
        date_administered: (patient.dob + 3.years)
      )
      expect(
        test_object.calculate_count_of_vaccine_doses(
          test_vaccine_doses,
          test_condition_object.vaccine_types,
          end_age_date: end_age_date
        )
      ).to eq(2)
    end
    it 'it includes only vaccines given after the start_date' do
      patient = all_vaccine_doses.first.patient
      start_date = Date.today - 3.months
      test_vaccine_doses = [FactoryGirl.create(
        :vaccine_dose_by_cvx,
        patient_profile: patient.patient_profile,
        cvx_code: 10,
        date_administered: (Date.today - 2.months)
      )]
      test_vaccine_doses << FactoryGirl.create(
        :vaccine_dose_by_cvx,
        patient_profile: patient.patient_profile,
        cvx_code: 10,
        date_administered: (Date.today - 4.months)
      )
      test_vaccine_doses << FactoryGirl.create(
        :vaccine_dose_by_cvx,
        patient_profile: patient.patient_profile,
        cvx_code: 10,
        date_administered: (Date.today - 6.months)
      )
      expect(
        test_object.calculate_count_of_vaccine_doses(
          test_vaccine_doses,
          test_condition_object.vaccine_types,
          start_date: start_date
        )
      ).to eq(1)
    end
    it 'it includes only vaccines given before the end_date' do
      patient = all_vaccine_doses.first.patient
      end_date = Date.today - 3.months
      test_vaccine_doses = [FactoryGirl.create(
        :vaccine_dose_by_cvx,
        patient_profile: patient.patient_profile,
        cvx_code: 10,
        date_administered: (Date.today - 2.months)
      )]
      test_vaccine_doses << FactoryGirl.create(
        :vaccine_dose_by_cvx,
        patient_profile: patient.patient_profile,
        cvx_code: 10,
        date_administered: (Date.today - 4.months)
      )
      test_vaccine_doses << FactoryGirl.create(
        :vaccine_dose_by_cvx,
        patient_profile: patient.patient_profile,
        cvx_code: 10,
        date_administered: (Date.today - 6.months)
      )
      expect(
        test_object.calculate_count_of_vaccine_doses(
          test_vaccine_doses,
          test_condition_object.vaccine_types,
          end_date: end_date
        )
      ).to eq(2)
    end
    it 'it includes only vaccines with evaluation_status Valid if vaccine'\
      'conditional skip dose type is Valid' do
      patient = all_vaccine_doses.first.patient
      test_vaccine_doses = [FactoryGirl.create(
        :vaccine_dose_by_cvx,
        patient_profile: patient.patient_profile,
        cvx_code: 10,
        date_administered: (Date.today - 2.months)
      )]
      test_vaccine_doses << FactoryGirl.create(
        :vaccine_dose_by_cvx,
        patient_profile: patient.patient_profile,
        cvx_code: 10,
        date_administered: (Date.today - 4.months)
      )
      test_vaccine_doses << FactoryGirl.create(
        :vaccine_dose_by_cvx,
        patient_profile: patient.patient_profile,
        cvx_code: 10,
        date_administered: (Date.today - 6.months)
      )
      expect(
        test_object.calculate_count_of_vaccine_doses(
          test_vaccine_doses,
          test_condition_object.vaccine_types,
          dose_type: 'Valid'
        )
      ).to eq(2)
    end
    it 'it includes all vaccines if vaccine'\
      'conditional skip dose type is Total' do
      patient = all_vaccine_doses.first.patient
      test_vaccine_doses = [FactoryGirl.create(
        :vaccine_dose_by_cvx,
        patient_profile: patient.patient_profile,
        cvx_code: 10,
        date_administered: (Date.today - 2.months)
      )]
      test_vaccine_doses << FactoryGirl.create(
        :vaccine_dose_by_cvx,
        patient_profile: patient.patient_profile,
        cvx_code: 10,
        date_administered: (Date.today - 4.months)
      )
      test_vaccine_doses << FactoryGirl.create(
        :vaccine_dose_by_cvx,
        patient_profile: patient.patient_profile,
        cvx_code: 10,
        date_administered: (Date.today - 6.months)
      )
      expect(
        test_object.calculate_count_of_vaccine_doses(
          test_vaccine_doses,
          test_condition_object.vaccine_types,
          dose_type: 'Total'
        )
      ).to eq(2)
    end

    # context 'when dose_type is \'Valid\'' do
    #   it 'returns an empty array if the cvx_codes is empty' do
    #     polio_vaccine_doses =
    #       test_object.match_vaccine_doses_with_cvx_codes(
    #         all_vaccine_doses,
    #         []
    #       )
    #     expect(polio_vaccine_doses.length).to eq(0)
    #   end
    #   it 'returns an empty array if there are no vaccines that match' do
    #     polio_vaccine_doses =
    #       test_object.match_vaccine_doses_with_cvx_codes(
    #         all_vaccine_doses,
    #         [12, 13, 14, 15]
    #       )
    #     expect(polio_vaccine_doses.length).to eq(0)
    #   end
    # end
  end
  describe '#evaluate_vaccine_dose_count' do
    # <doseCount>5</doseCount>
    # <doseType>Total</doseType>
    # <doseCountLogic>greater than</doseCountLogic>
    # <vaccineTypes>01;09;20;22;28;50;102;106;107;110;113;115;120;130;132;138;139;146</vaccineTypes>
    dose_count_hash = {
      'greater than' => [false, false, true],
      'equals' => [false, true, false],
      'less than' => [true, false, false]
    }
    dose_counts = [4, 5, 6]
    required_dose_count = 5
    dose_count_hash.each do |dose_count_logic, values|
      dose_counts.each_with_index do |actual_dose_count, index|
        expected_return_value = values[index]
        it "returns #{expected_return_value} for logic #{dose_count_logic} " \
           "with a required_dose_count of #{required_dose_count} and " \
           "actual dose count of #{actual_dose_count}" do
          result = test_object.evaluate_vaccine_dose_count(
            dose_count_logic,
            required_dose_count,
            actual_dose_count
          )
          expect(result).to eq(expected_return_value)
        end
      end
    end
  end
  describe '#evaluate_conditional_skip_set_condition_attributes' do
    let(:valid_condition_attrs) do
      {
        begin_age_date: 10.months.ago.to_date,
        end_age_date: 2.months.ago.to_date,
        start_date: 10.months.ago.to_date,
        end_date: 2.months.ago.to_date,
        assessment_date: Date.today.to_date,
        condition_id: 1,
        condition_type: 'Age',
        interval_date: 5.days.ago.to_date,
        dose_count: 5,
        dose_type: 'Total',
        dose_count_logic: 'greater_than',
        vaccine_types: [1, 10, 20, 22, 28, 50, 102, 106, 107, 110, 113,
                        115, 120, 130, 132, 138, 139, 146]
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
            .evaluate_conditional_skip_set_condition_attributes(
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
            .evaluate_conditional_skip_set_condition_attributes(
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
            .evaluate_conditional_skip_set_condition_attributes(
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
            .evaluate_conditional_skip_set_condition_attributes(
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
            .evaluate_conditional_skip_set_condition_attributes(
              valid_condition_attrs,
              dose_date
            )
          expect(eval_hash[:end_date]).to eq(value[1])
        end
      end
    end
  end
  describe '#get_conditional_skip_set_condition_status' do
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

      it "returns status: #{expected_status}, reason: #{expected_reason}, " \
         "evaluated: #{evaluated} for #{input_key}: #{input_value}" do
         eval_hash[input_key.to_sym] = input_value

         status_hash = test_object.get_conditional_skip_set_condition_status(
           eval_hash
         )
         expect(status_hash[:status]).to eq(expected_status)
         expect(status_hash[:reason]).to eq(expected_reason)
         expect(status_hash[:evaluated]).to eq(evaluated)
      end
    end
  end
  describe '#evaluate_conditional_skip_set ' do
    condition_statuses_hash = {
      all_met:  [{status: 'condition_met'}, {status: 'condition_met'}],
      one_met:  [{status: 'condition_met'}, {status: 'condition_not_met'}],
      none_met: [{status: 'condition_not_met'}, {status: 'condition_not_met'}]
    }

    {
      AND: [['all_met', 'set_met'],
            ['one_met', 'set_not_met'],
            ['none_met', 'set_not_met']
           ],
      OR: [['all_met', 'set_met'],
           ['one_met', 'set_met'],
           ['none_met', 'set_not_met']
          ]
    }.each do |condition_logic, value_arrays|
      value_arrays.each do |value_array|
        expected_status    = value_array[1]
        statuses_key       = value_array[0]
        condition_statuses = condition_statuses_hash[statuses_key.to_sym]
        it "takes condition_logic #{condition_logic} with condition statuses" \
           " with #{statuses_key} and returns status: #{expected_status}" do
          result_hash = test_object.evaluate_conditional_skip_set(
            condition_logic.to_s,
            condition_statuses
          )
          expect(result_hash[:status]).to eq(expected_status)
          expect(result_hash[:evaluated]).to eq('conditional_skip_set')
        end
      end
    end

    it 'raises an error if the condition_statuses_array is empty' do
      expect{
        test_object.evaluate_conditional_skip_set('AND', [])
      }.to raise_exception(ArgumentError)
    end
  end
  describe '#evaluate_conditional_skip ' do
    set_statuses_hash = {
      all_met:  [{status: 'set_met'}, {status: 'set_met'}],
      one_met:  [{status: 'set_met'}, {status: 'set_not_met'}],
      none_met: [{status: 'set_not_met'}, {status: 'set_not_met'}]
    }

    {
      AND: [['all_met', 'conditional_skip_met'],
            ['one_met', 'conditional_skip_not_met'],
            ['none_met', 'conditional_skip_not_met']
           ],
      OR: [['all_met', 'conditional_skip_met'],
           ['one_met', 'conditional_skip_met'],
           ['none_met', 'conditional_skip_not_met']
          ]
    }.each do |set_logic, value_arrays|
      value_arrays.each do |value_array|
        expected_status    = value_array[1]
        statuses_key       = value_array[0]
        condition_statuses = set_statuses_hash[statuses_key.to_sym]
        it "takes condition_logic #{set_logic} with condition statuses " \
           "with #{statuses_key} and returns status: #{expected_status}" do
          result_hash = test_object.evaluate_conditional_skip(
            set_logic.to_s,
            condition_statuses
          )
          expect(result_hash[:status]).to eq(expected_status)
          expect(result_hash[:evaluated]).to eq('conditional_skip')
        end
      end
    end

    it 'raises an error if the condition_statuses_array is empty' do
      expect{
        test_object.evaluate_conditional_skip('AND', [])
      }.to raise_exception(ArgumentError)
    end
  end
  describe '#evaluate_conditional_skip_set_condition ' do
    it 'takes a condition with condition, patient_dob, date_of_dose, ' \
    'patient_vaccine_doses, date_of_previous_dose and returns a status hash' do
      condition_object = condition1
      patient_dob      = test_patient.dob
      vaccine_doses    = test_patient.vaccine_doses
      vaccine_dose     = vaccine_doses.first
      date_of_dose     = vaccine_dose.date_administered
      evaluation_hash = test_object.evaluate_conditional_skip_set_condition(
        condition_object,
        patient_dob,
        date_of_dose,
        patient_vaccine_doses: vaccine_doses
      )
      expect(evaluation_hash).to eq({status: 'GOOD'})
    end
  end
end
