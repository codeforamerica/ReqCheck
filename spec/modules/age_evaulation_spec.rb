require 'rails_helper'
require 'age_evaluation'

RSpec.describe AgeEvaluation do
  include AntigenImporterSpecHelper

  before(:all) { seed_antigen_xml_polio }
  after(:all) { DatabaseCleaner.clean_with(:truncation) }

  let(:test_object) do
    class TestClass
      include AgeEvaluation
    end
    TestClass.new
  end

  let(:condition_object) do
    FactoryGirl.create(:conditional_skip_condition)
  end

  let(:test_patient) do
    test_patient = FactoryGirl.create(:patient)
    FactoryGirl.create(
      :vaccine_dose,
      patient: test_patient,
      vaccine_code: 'IPV',
      date_administered: (test_patient.dob + 7.weeks)
    )
    FactoryGirl.create(
      :vaccine_dose,
      patient: test_patient,
      vaccine_code: 'IPV',
      date_administered: (test_patient.dob + 11.weeks)
    )
    test_patient.reload
    test_patient
  end

  let(:polio_antigen_series_dose) do
    AntigenSeriesDose
      .joins(:antigen_series)
      .joins(
        'INNER JOIN "antigens" ON "antigens"."id" ' \
        '= "antigen_series"."antigen_id"'
      ).where(antigens: { target_disease: 'polio' }).first
  end

  describe '#evaluate_age_attributes' do
    let(:valid_age_attrs) do
      {
        absolute_min_age_date: 12.months.ago.to_date,
        min_age_date: 10.months.ago.to_date,
        earliest_recommended_age_date: 8.months.ago.to_date,
        latest_recommended_age_date: 2.months.ago.to_date,
        max_age_date: 1.month.ago.to_date
      }
    end
    it 'returns a hash that does not include \'_date\' in the keys' do
      dose_date = 6.months.ago.to_date
      eval_hash = test_object.evaluate_age_attributes(valid_age_attrs,
                                                     dose_date)
      expect(eval_hash.class).to eq(Hash)
      eval_hash.each do |key, _value|
        expect(key.to_s.include?('_date')).to eq(false)
      end
    end
    describe 'for each minimum age attribute' do
      dose_date = 9.months.ago.to_date
      attribute_options = {
        before_the_dose_date: [10.months.ago.to_date, true],
        after_the_dose_date: [8.months.ago.to_date, false],
        nil: [nil, nil]
      }
      %w(absolute_min_age_date min_age_date earliest_recommended_age_date)
        .each do |attribute|
          attribute_options.each do |descriptor, value|
            descriptor_string = "returns #{value[1]} when the #{attribute}" \
                                " attribute is #{descriptor}"
            it descriptor_string do
              valid_age_attrs[attribute.to_sym] = value[0]
              eval_hash = test_object.evaluate_age_attributes(valid_age_attrs,
                                                             dose_date)
              result_key = attribute.split('_')[0..-2].join('_').to_sym
              expect(eval_hash[result_key.to_sym]).to eq(value[1])
            end
          end
        end
    end
    describe 'for each max age attribute' do
      dose_date = 9.months.ago.to_date
      attribute_options = {
        before_the_dose_date: [10.months.ago.to_date, false],
        after_the_dose_date: [8.months.ago.to_date, true],
        nil: [nil, nil]
      }
      %w(latest_recommended_age_date max_age_date)
        .each do |attribute|
          attribute_options.each do |descriptor, value|
            descriptor_string = "returns #{value[1]} when the #{attribute}"\
                                " attribute is #{descriptor}"
            it descriptor_string do
              valid_age_attrs[attribute.to_sym] = value[0]
              eval_hash = test_object.evaluate_age_attributes(valid_age_attrs,
                                                             dose_date)
              result_key = attribute.split('_')[0..-2].join('_').to_sym
              expect(eval_hash[result_key.to_sym]).to eq(value[1])
            end
          end
        end
    end
  end

  describe '#get_age_status' do
    # This logic is defined on page 38 of the CDC logic spec
    it 'returns not_valid, too young for absolute_min_age false' do
      prev_status_hash = nil
      age_eval_hash = {
        absolute_min_age: false,
        min_age: false,
        earliest_recommended_age: false,
        latest_recommended_age: true,
        max_age: true
      }
      expected_result = { evaluation_status: 'not_valid',
                          evaluated: 'age',
                          details: 'too_young' }
                          # record: polio_antigen_series_dose }
      expect(
        test_object.get_age_status(age_eval_hash,
                                   # polio_antigen_series_dose,
                                   prev_status_hash)
      ).to eq(expected_result)
    end

    it 'returns not_valid, too young for before min_age and previous not_valid' do
      prev_status_hash = {
        evaluation_status: 'not_valid',
        reason: 'age',
        details: 'too_young'
      }
      age_eval_hash = {
        absolute_min_age: true,
        min_age: false,
        earliest_recommended_age: false,
        latest_recommended_age: true,
        max_age: true
      }
      expected_result = { evaluation_status: 'not_valid',
                          evaluated: 'age',
                          details: 'too_young' }
                          # record: polio_antigen_series_dose }
      expect(
        test_object.get_age_status(age_eval_hash,
                                   # polio_antigen_series_dose,
                                   prev_status_hash)
      ).to eq(expected_result)
    end

    it 'returns valid, grace_period for before min_age and previous valid' do
      prev_status_hash = {
        evaluation_status: 'valid',
        details: 'grace_period'
      }
      age_eval_hash = {
        absolute_min_age: true,
        min_age: false,
        earliest_recommended_age: false,
        latest_recommended_age: true,
        max_age: true
      }
      expected_result = { evaluation_status: 'valid',
                          evaluated: 'age',
                          details: 'grace_period' }
                          # record: polio_antigen_series_dose }
      expect(
        test_object.get_age_status(age_eval_hash,
                                   # polio_antigen_series_dose,
                                   prev_status_hash)
      ).to eq(expected_result)
    end
    it 'returns valid, grace_period for before min_age yet first dose' do
      prev_status_hash = nil
      age_eval_hash = {
        absolute_min_age: true,
        min_age: false,
        earliest_recommended_age: false,
        latest_recommended_age: true,
        max_age: true
      }
      expected_result = { evaluation_status: 'valid',
                          evaluated: 'age',
                          details: 'grace_period' }
                          # record: polio_antigen_series_dose }
      expect(
        test_object.get_age_status(age_eval_hash,
                                   # polio_antigen_series_dose,
                                   prev_status_hash)
      ).to eq(expected_result)
    end
    it 'returns valid for after min_age and before max_age' do
      prev_status_hash = nil
      age_eval_hash = {
        absolute_min_age: true,
        min_age: true,
        earliest_recommended_age: false,
        latest_recommended_age: true,
        max_age: true
      }
      expected_result = { evaluation_status: 'valid',
                          evaluated: 'age',
                          details: 'on_schedule' }
                          # record: polio_antigen_series_dose }
      expect(
        test_object.get_age_status(age_eval_hash,
                                   # polio_antigen_series_dose,
                                   prev_status_hash)
      ).to eq(expected_result)
    end
    it 'returns not_valid, too_old for after max_age' do
      prev_status_hash = nil
      age_eval_hash = {
        absolute_min_age: true,
        min_age: true,
        earliest_recommended_age: true,
        latest_recommended_age: false,
        max_age: false
      }
      expected_result = { evaluation_status: 'not_valid',
                          evaluated: 'age',
                          details: 'too_old' }
                          # record: polio_antigen_series_dose }
      expect(
        test_object.get_age_status(age_eval_hash,
                                   # polio_antigen_series_dose,
                                   prev_status_hash)
      ).to eq(expected_result)
    end
  end
  describe '#evaluate_age ' do
    it 'takes a evaluation_antigen_series_dose, patient_dob, date_of_dose ' \
       'and previous_dose_status_hash and returns a status hash' do
      expect(polio_antigen_series_dose.min_age).to eq('6 weeks')
      expect(polio_antigen_series_dose.absolute_min_age)
        .to eq('6 weeks - 4 days')
      expect(polio_antigen_series_dose.earliest_recommended_age)
        .to eq('2 months')
      patient_dob             = 1.year.ago.to_date
      date_of_dose            = (1.year.ago + 6.weeks).to_date
      evaluation_hash = test_object.evaluate_age(
        polio_antigen_series_dose,
        patient_dob: patient_dob,
        date_of_dose: date_of_dose
      )
      expected_result = {
                          evaluation_status: 'valid',
                          evaluated: 'age',
                          details: 'on_schedule'
                        }
      expect(evaluation_hash).to eq(expected_result)
    end
    it 'returns not_valid for not_valid patient age at dose date' do
      expect(polio_antigen_series_dose.min_age).to eq('6 weeks')
      expect(polio_antigen_series_dose.absolute_min_age)
        .to eq('6 weeks - 4 days')
      expect(polio_antigen_series_dose.earliest_recommended_age)
        .to eq('2 months')
      patient_dob             = 1.year.ago.to_date
      date_of_dose            = (1.year.ago + 4.weeks).to_date
      evaluation_hash = test_object.evaluate_age(
        polio_antigen_series_dose,
        patient_dob: patient_dob,
        date_of_dose: date_of_dose
      )
      expected_result = {
                          evaluation_status: 'not_valid',
                          evaluated: 'age',
                          details: 'too_young'
                        }
      expect(evaluation_hash).to eq(expected_result)
    end
  end
end
