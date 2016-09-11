require 'rails_helper'
require 'preferable_allowable_vaccine_evaluation'

RSpec.describe PreferableAllowableVaccineEvaluation do
  before(:all) { FactoryGirl.create(:seed_antigen_xml_polio) }
  after(:all) { DatabaseCleaner.clean_with(:truncation) }

  let(:test_object) do
    class TestClass
      include PreferableAllowableVaccineEvaluation
    end
    TestClass.new
  end

  let(:as_dose_vaccine) { FactoryGirl.create(:antigen_series_dose_vaccine) }
  let(:as_dose) { FactoryGirl.create(:antigen_series_dose_with_vaccines) }

  describe '#create_vaccine_attributes' do
    it 'returns a hash with 4 attributes' do
      dob = 1.year.ago.to_date
      as_dose_vaccine.begin_age = '6 weeks'
      expected_begin_age = dob + 6.weeks
      as_dose_vaccine.end_age = '5 years'
      expected_end_age = dob + 5.years

      as_dose_vaccine.trade_name = 'test'
      expected_trade_name = 'test'
      as_dose_vaccine.volume = '0.5'
      expected_volume = '0.5'
      vaccine_attrs = test_object.create_vaccine_attributes(
        as_dose_vaccine,
        dob
      )
      expect(vaccine_attrs[:expected_trade_name]).to eq(expected_trade_name)
      expect(vaccine_attrs[:expected_volume]).to eq(expected_volume)
      expect(vaccine_attrs[:begin_age_date])
        .to eq(expected_begin_age)
      expect(vaccine_attrs[:end_age_date])
        .to eq(expected_end_age)
    end
    %w(
      begin_age_date end_age_date
    ).each do |vaccine_attr|
      it "creates a hash with the attribute #{vaccine_attr}" do
        dob = 2.years.ago.to_date
        vaccine_attrs = test_object.create_vaccine_attributes(
          as_dose_vaccine,
          dob
        )
        abr_attribute = vaccine_attr.split('_')[0...-1].join('_')
        vaccine_time_string = as_dose_vaccine.send(abr_attribute)
        expect(vaccine_time_string.nil?).to be(false)
        vaccine_age_date = test_object.create_patient_age_date(
          vaccine_time_string, dob
        )
        expect(vaccine_attrs[vaccine_attr.to_sym])
          .to eq(vaccine_age_date)
        expect(vaccine_attrs[vaccine_attr.to_sym].class.name)
          .to eq('Date')
      end
    end
    describe 'default values' do
      # As described on page 38 on CDC logic specs
      # 'http://www.cdc.gov/vaccines/programs/iis/interop-proj/'\
      #   'downloads/logic-spec-acip-rec.pdf'
      it 'sets default value for begin_age_date' do
        dob = 2.years.ago.to_date
        as_dose_vaccine.begin_age = nil
        vaccine_attrs = test_object.create_vaccine_attributes(
          as_dose_vaccine,
          dob
        )
        expect(
          vaccine_attrs[:begin_age_date]
        ).to eq('01/01/1900'.to_date)
      end
      it 'sets default value for end_age_date' do
        dob = 2.years.ago.to_date
        as_dose_vaccine.end_age = nil
        vaccine_attrs = test_object.create_vaccine_attributes(
          as_dose_vaccine,
          dob
        )
        expect(vaccine_attrs[:end_age_date])
          .to eq('12/31/2999'.to_date)
      end
    end
  end

  describe '#evaluate_vaccine_attributes' do
    let(:valid_vaccine_attrs) do
      {
        begin_age_date: 10.months.ago.to_date,
        end_age_date: 2.months.ago.to_date,
        expected_trade_name: 'test',
        expected_volume: '0.5'
      }
    end
    describe 'for each minimum age attribute' do
      administered_dose_date = 6.weeks.ago.to_date
      attribute_options = {
        before_the_dose_date: [8.weeks.ago.to_date, true],
        after_the_dose_date: [4.weeks.ago.to_date, false],
        nil: [nil, nil]
      }
      %w(
        begin_age_date
      ).each do |attribute|
        attribute_options.each do |descriptor, value|
          descriptor_string = "returns #{value[1]} when the #{attribute}"\
                              " attribute is #{descriptor}"
          it descriptor_string do
            valid_vaccine_attrs[attribute.to_sym] = value[0]
            eval_hash = test_object.evaluate_vaccine_attributes(
              valid_vaccine_attrs,
              administered_dose_date,
              'test',
              '0.5'
            )
            result_key = attribute.split('_')[0..-2].join('_').to_sym
            expect(eval_hash[result_key]).to eq(value[1])
          end
        end
      end
    end
    describe 'for each max age attribute' do
      administered_dose_date = 6.weeks.ago.to_date
      attribute_options = {
        before_the_dose_date: [8.weeks.ago.to_date, false],
        after_the_dose_date: [4.weeks.ago.to_date, true],
        nil: [nil, nil]
      }
      %w(
        end_age_date
      ).each do |attribute|
        attribute_options.each do |descriptor, value|
          descriptor_string = "returns #{value[1]} when the #{attribute}"\
                              " attribute is #{descriptor}"
          it descriptor_string do
            valid_vaccine_attrs[attribute.to_sym] = value[0]
            eval_hash = test_object.evaluate_vaccine_attributes(
              valid_vaccine_attrs,
              administered_dose_date,
              'test',
              '0.5'
            )
            result_key = attribute.split('_')[0..-2].join('_').to_sym
            expect(eval_hash[result_key]).to eq(value[1])
          end
        end
      end
    end
    describe 'for the trade_name attribute' do
      it 'returns true when dose trade_name equals expected_trade_name' do
        valid_vaccine_attrs[:expected_trade_name] = 'tester'
        eval_hash = test_object.evaluate_vaccine_attributes(
          valid_vaccine_attrs,
          Date.today,
          'tester',
          '0.5'
        )
        expect(eval_hash[:trade_name]).to eq(true)
      end
      it 'returns false when dose trade_name equals expected_trade_name' do
        valid_vaccine_attrs[:expected_trade_name] = 'tester'
        eval_hash = test_object.evaluate_vaccine_attributes(
          valid_vaccine_attrs,
          Date.today,
          'NOT TESTER',
          '0.5'
        )
        expect(eval_hash[:trade_name]).to eq(false)
      end
    end
    describe 'for the volume attribute' do
      it 'returns true when dose volume is equal to expected_volume' do
        valid_vaccine_attrs[:expected_volume] = '0.5'
        eval_hash = test_object.evaluate_vaccine_attributes(
          valid_vaccine_attrs,
          Date.today,
          'tester',
          '0.5'
        )
        expect(eval_hash[:volume]).to eq(true)
      end
      it 'returns true when dose volume is greater than expected_volume' do
        valid_vaccine_attrs[:expected_volume] = '0.5'
        eval_hash = test_object.evaluate_vaccine_attributes(
          valid_vaccine_attrs,
          Date.today,
          'tester',
          '0.9'
        )
        expect(eval_hash[:volume]).to eq(true)
      end
      it 'returns false when dose volume is less than expected_volume' do
        valid_vaccine_attrs[:expected_volume] = '0.5'
        eval_hash = test_object.evaluate_vaccine_attributes(
          valid_vaccine_attrs,
          Date.today,
          'tester',
          '0.3'
        )
        expect(eval_hash[:volume]).to eq(false)
      end
      it 'returns false when dose volume is nil' do
        valid_vaccine_attrs[:expected_volume] = '0.5'
        eval_hash = test_object.evaluate_vaccine_attributes(
          valid_vaccine_attrs,
          Date.today,
          'tester',
          nil
        )
        expect(eval_hash[:volume]).to eq(false)
      end
    end
  end

  describe '#get_preferable_vaccine_status' do
    # This logic is defined on page 50 of the CDC logic spec
    xit 'returns invalid, preferable, not_preferable for preferable false' do
      prev_status_hash = nil
      vaccine_eval_hash = {
        begin_age: true,
        end_age: true,
        trade_name: true,
        volume: true
      }
      expected_result = { status: 'invalid',
                          evaluated: 'preferable',
                          details: 'not_preferable' }
      expect(
        test_object.get_preferable_vaccine_status(vaccine_eval_hash,
                                                  prev_status_hash)
      ).to eq(expected_result)
    end

    it 'returns invalid, preferable, out_of_age_range for '\
    'begin_age false' do
      prev_status_hash = nil
      vaccine_eval_hash = {
        begin_age: false,
        end_age: true,
        trade_name: true,
        volume: true
      }
      expected_result = { status: 'invalid',
                          evaluated: 'preferable',
                          details: 'out_of_age_range' }
      expect(
        test_object.get_preferable_vaccine_status(vaccine_eval_hash,
                                                  prev_status_hash)
      ).to eq(expected_result)
    end

    it 'returns invalid, preferable, out_of_age_range for '\
    'end_age false' do
      prev_status_hash = nil
      vaccine_eval_hash = {
        begin_age: true,
        end_age: false,
        trade_name: true,
        volume: true
      }
      expected_result = { status: 'invalid',
                          evaluated: 'preferable',
                          details: 'out_of_age_range' }
      expect(
        test_object.get_preferable_vaccine_status(vaccine_eval_hash,
                                                  prev_status_hash)
      ).to eq(expected_result)
    end

    it 'returns invalid, preferable, wrong_trade_name for '\
    'trade_name false' do
      prev_status_hash = nil
      vaccine_eval_hash = {
        begin_age: true,
        end_age: true,
        trade_name: false,
        volume: true
      }
      expected_result = { status: 'invalid',
                          evaluated: 'preferable',
                          details: 'wrong_trade_name' }
      expect(
        test_object.get_preferable_vaccine_status(vaccine_eval_hash,
                                                  prev_status_hash)
      ).to eq(expected_result)
    end

    it 'returns valid, preferable, less_than_recommended_volume for ' \
      'volume false' do
      prev_status_hash = nil
      vaccine_eval_hash = {
        begin_age: true,
        end_age: true,
        trade_name: true,
        volume: false
      }
      expected_result = { status: 'valid',
                          evaluated: 'preferable',
                          details: 'less_than_recommended_volume' }
      expect(
        test_object.get_preferable_vaccine_status(vaccine_eval_hash,
                                                  prev_status_hash)
      ).to eq(expected_result)
    end
    it 'returns valid, preferable for all true' do
      prev_status_hash = nil
      vaccine_eval_hash = {
        begin_age: true,
        end_age: true,
        trade_name: true,
        volume: true
      }
      expected_result = { status: 'valid',
                          evaluated: 'preferable',
                          details: 'within_age_trade_name_volume' }
      expect(
        test_object.get_preferable_vaccine_status(vaccine_eval_hash,
                                                  prev_status_hash)
      ).to eq(expected_result)
    end
  end

  describe '#get_allowable_vaccine_status' do
    # This logic is defined on page 52 of the CDC logic spec
    xit 'returns invalid, allowable, not_allowable for allowable false' do
      prev_status_hash = nil
      vaccine_eval_hash = {
        begin_age: true,
        end_age: true,
        trade_name: true,
        volume: true
      }
      expected_result = { status: 'invalid',
                          evaluated: 'allowable',
                          details: 'not_allowable' }
      expect(
        test_object.get_allowable_vaccine_status(vaccine_eval_hash,
                                                 prev_status_hash)
      ).to eq(expected_result)
    end

    it 'returns invalid, allowable, out_of_age_range for '\
    'begin_age false' do
      prev_status_hash = nil
      vaccine_eval_hash = {
        begin_age: false,
        end_age: true,
        trade_name: true,
        volume: true
      }
      expected_result = { status: 'invalid',
                          evaluated: 'allowable',
                          details: 'out_of_age_range' }
      expect(
        test_object.get_allowable_vaccine_status(vaccine_eval_hash,
                                                 prev_status_hash)
      ).to eq(expected_result)
    end

    it 'returns invalid, allowable, out_of_age_range for '\
    'end_age false' do
      prev_status_hash = nil
      vaccine_eval_hash = {
        begin_age: true,
        end_age: false,
        trade_name: true,
        volume: true
      }
      expected_result = { status: 'invalid',
                          evaluated: 'allowable',
                          details: 'out_of_age_range' }
      expect(
        test_object.get_allowable_vaccine_status(vaccine_eval_hash,
                                                 prev_status_hash)
      ).to eq(expected_result)
    end
    it 'returns valid, allowable for all true' do
      prev_status_hash = nil
      vaccine_eval_hash = {
        begin_age: true,
        end_age: true,
        trade_name: true,
        volume: true
      }
      expected_result = { status: 'valid',
                          evaluated: 'allowable',
                          details: 'within_age_range' }
      expect(
        test_object.get_allowable_vaccine_status(vaccine_eval_hash,
                                                 prev_status_hash)
      ).to eq(expected_result)
    end
  end
  describe '#evaluate_preferable_allowable_vaccine_dose_requirement' do
    context 'with preferable vaccines' do
      it 'takes a evaluation_antigen_series_dose_vaccine, patient_dob, ' \
      'date_of_dose, dose_trade_name, dose_volume and returns a status hash' do
        patient_dob  = 2.years.ago.to_date
        date_of_dose = 1.year.ago.to_date
        trade_name   = 'test'
        volume       = '0.5'
        expect(as_dose_vaccine.begin_age).to eq('6 weeks')
        expect(as_dose_vaccine.end_age).to eq('5 years')
        evaluation_hash =
          test_object.evaluate_preferable_allowable_vaccine_dose_requirement(
            as_dose_vaccine,
            patient_dob: patient_dob,
            date_of_dose: date_of_dose,
            dose_trade_name: trade_name,
            dose_volume: volume
          )
        expected_result = {
                            status: 'valid',
                            evaluated: 'preferable',
                            details: 'within_age_trade_name_volume'
                          }
        expect(evaluation_hash).to eq(expected_result)
      end
      it 'returns invalid for invalid patient age at dose date' do
        patient_dob  = 2.years.ago.to_date
        date_of_dose = (2.year.ago + 4.weeks).to_date
        trade_name   = 'test'
        volume       = '0.5'
        expect(as_dose_vaccine.begin_age).to eq('6 weeks')
        expect(as_dose_vaccine.end_age).to eq('5 years')
        evaluation_hash =
          test_object.evaluate_preferable_allowable_vaccine_dose_requirement(
            as_dose_vaccine,
            patient_dob: patient_dob,
            date_of_dose: date_of_dose,
            dose_trade_name: trade_name,
            dose_volume: volume
          )
        expected_result = {
                            status: 'invalid',
                            evaluated: 'preferable',
                            details: 'out_of_age_range'
                          }
        expect(evaluation_hash).to eq(expected_result)
      end
    end
    context 'with allowable vaccines' do
      it 'takes a evaluation_antigen_series_dose_vaccine, patient_dob, ' \
      'date_of_dose, dose_trade_name, dose_volume and returns a status hash' do
        patient_dob  = 2.years.ago.to_date
        date_of_dose = 1.year.ago.to_date
        trade_name   = 'test'
        volume       = '0.5'
        expect(as_dose_vaccine.begin_age).to eq('6 weeks')
        expect(as_dose_vaccine.end_age).to eq('5 years')
        as_dose_vaccine.preferable = false
        evaluation_hash =
          test_object.evaluate_preferable_allowable_vaccine_dose_requirement(
            as_dose_vaccine,
            patient_dob: patient_dob,
            date_of_dose: date_of_dose,
            dose_trade_name: trade_name,
            dose_volume: volume
          )
        expected_result = { status: 'valid',
                            evaluated: 'allowable',
                            details: 'within_age_range' }
        expect(evaluation_hash).to eq(expected_result)
      end
      it 'returns invalid for invalid patient age at dose date' do
        patient_dob  = 2.years.ago.to_date
        date_of_dose = (2.year.ago + 4.weeks).to_date
        trade_name   = 'test'
        volume       = '0.5'
        expect(as_dose_vaccine.begin_age).to eq('6 weeks')
        expect(as_dose_vaccine.end_age).to eq('5 years')
        as_dose_vaccine.preferable = false
        evaluation_hash =
          test_object.evaluate_preferable_allowable_vaccine_dose_requirement(
            as_dose_vaccine,
            patient_dob: patient_dob,
            date_of_dose: date_of_dose,
            dose_trade_name: trade_name,
            dose_volume: volume
          )
        expected_result = { status: 'invalid',
                            evaluated: 'allowable',
                            details: 'out_of_age_range' }
        expect(evaluation_hash).to eq(expected_result)
      end
    end
    describe '#evaluate_vaccine_dose_for_preferable_allowable' do
      it 'returns preferable vaccine status if preferable vaccine' do
        patient_dob  = 2.years.ago.to_date
        date_of_dose = 1.year.ago.to_date
        trade_name   = 'test'
        volume       = '0.5'
        cvx_code     = 10
        evaluation_hash =
          test_object.evaluate_vaccine_dose_for_preferable_allowable(
            as_dose,
            patient_dob: patient_dob,
            dose_cvx: cvx_code,
            date_of_dose: date_of_dose,
            dose_trade_name: trade_name,
            dose_volume: volume
          )
        expected_result = { status: 'valid',
                            evaluated: 'preferable',
                            details: 'within_age_trade_name_volume' }
        expect(evaluation_hash).to eq(expected_result)
      end
      it 'returns invalid preferable vaccine status if preferable vaccine' do
        patient_dob  = 2.years.ago.to_date
        date_of_dose = (2.years.ago + 4.weeks).to_date
        trade_name   = 'test'
        volume       = '0.5'
        cvx_code     = 10
        evaluation_hash =
          test_object.evaluate_vaccine_dose_for_preferable_allowable(
            as_dose,
            patient_dob: patient_dob,
            dose_cvx: cvx_code,
            date_of_dose: date_of_dose,
            dose_trade_name: trade_name,
            dose_volume: volume
          )
        expected_result = { status: 'invalid',
                            evaluated: 'preferable',
                            details: 'out_of_age_range' }
        expect(evaluation_hash).to eq(expected_result)
      end
      it 'returns invalid if no vaccine is found' do
        patient_dob  = 2.years.ago.to_date
        date_of_dose = 1.year.ago.to_date
        trade_name   = 'test'
        volume       = '0.5'
        cvx_code     = 3
        evaluation_hash =
          test_object.evaluate_vaccine_dose_for_preferable_allowable(
            as_dose,
            patient_dob: patient_dob,
            dose_cvx: cvx_code,
            date_of_dose: date_of_dose,
            dose_trade_name: trade_name,
            dose_volume: volume
          )
        expected_result = { status: 'invalid',
                            evaluated: 'allowable',
                            details: 'vaccine_cvx_not_found' }
        expect(evaluation_hash).to eq(expected_result)
      end
      it 'returns allowable vaccine status if preferable vaccine' do
        patient_dob  = 2.years.ago.to_date
        date_of_dose = 1.year.ago.to_date
        trade_name   = 'test'
        volume       = '0.5'
        cvx_code     = 130
        evaluation_hash =
          test_object.evaluate_vaccine_dose_for_preferable_allowable(
            as_dose,
            patient_dob: patient_dob,
            dose_cvx: cvx_code,
            date_of_dose: date_of_dose,
            dose_trade_name: trade_name,
            dose_volume: volume
          )
        expected_result = { status: 'valid',
                            evaluated: 'allowable',
                            details: 'within_age_range' }
        expect(evaluation_hash).to eq(expected_result)
      end
      it 'returns invalid allowable vaccine status if preferable vaccine' do
        patient_dob  = 2.years.ago.to_date
        date_of_dose = (2.years.ago + 4.weeks).to_date
        trade_name   = 'test'
        volume       = '0.5'
        cvx_code     = 130
        evaluation_hash =
          test_object.evaluate_vaccine_dose_for_preferable_allowable(
            as_dose,
            patient_dob: patient_dob,
            dose_cvx: cvx_code,
            date_of_dose: date_of_dose,
            dose_trade_name: trade_name,
            dose_volume: volume
          )
        expected_result = { status: 'invalid',
                            evaluated: 'allowable',
                            details: 'out_of_age_range' }
        expect(evaluation_hash).to eq(expected_result)
      end
    end
  end
end
