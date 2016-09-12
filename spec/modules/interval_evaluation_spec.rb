require 'rails_helper'
require 'interval_evaluation'

RSpec.describe IntervalEvaluation do
  before(:all) { FactoryGirl.create(:seed_antigen_xml_polio) }
  after(:all) { DatabaseCleaner.clean_with(:truncation) }

  let(:test_object) do
    class TestClass
      include IntervalEvaluation
    end
    TestClass.new
  end

  let(:test_patient) do
    test_patient = FactoryGirl.create(:patient)
    FactoryGirl.create(
      :vaccine_dose,
      patient_profile: test_patient.patient_profile,
      vaccine_code: 'IPV',
      date_administered: (test_patient.dob + 7.weeks)
    )
    FactoryGirl.create(
      :vaccine_dose,
      patient_profile: test_patient.patient_profile,
      vaccine_code: 'IPV',
      date_administered: (test_patient.dob + 11.weeks)
    )
    test_patient.reload
    test_patient
  end

  let(:test_interval) { FactoryGirl.create(:interval) }

  let(:as_dose_w_interval) do
    as_dose = FactoryGirl.create(:antigen_series_dose)
    as_dose.intervals << test_interval
    as_dose
  end

  let(:test_aars) do
    vaccine_doses = []
    vaccine_doses << FactoryGirl.create(
      :vaccine_dose,
      patient_profile: test_patient.patient_profile,
      date_administered: 5.month.ago.to_date
    )
    vaccine_doses << FactoryGirl.create(
      :vaccine_dose,
      patient_profile: test_patient.patient_profile,
      date_administered: 3.month.ago.to_date
    )
    AntigenAdministeredRecord.create_records_from_vaccine_doses(
      vaccine_doses
    )
  end

  xdescribe '#evaluate_interval' do
    #
    # HOW/WHAT IS ALLOWABLE INTERVAL EFFECTED?
    #

    it 'takes two records and returns valid if the interval is valid' do
      expect(as_dose_w_interval.intervals.first.interval_absolute_min)
        .to eq('4 weeks - 4 days')
      interval_eval = test_object.evaluate_interval(test_aars[0], test_aars[1])
      expect(interval_eval).to eq([{ evaluation_status: 'valid', reason: 'whatever' }])
    end
  end

  describe '#create_interval_attributes' do
    it 'returns a hash with the original date plus the date string diff' do
      origin_date = 1.year.ago.to_date
      test_interval.interval_absolute_min = '5 weeks - 4 days'
      abs_min = origin_date + 5.weeks - 4.days
      test_interval.interval_min = '5 weeks'
      min = origin_date + 5.weeks
      test_interval.interval_earliest_recommended = '9 weeks'
      earliest_rec = origin_date + 9.weeks
      test_interval.interval_latest_recommended = '14 weeks'
      latest_rec = origin_date + 14.weeks
      interval_attrs = test_object.create_interval_attributes(
        test_interval,
        origin_date
      )
      expect(interval_attrs[:interval_absolute_min_date]).to eq(abs_min)
      expect(interval_attrs[:interval_min_date]).to eq(min)
      expect(interval_attrs[:interval_earliest_recommended_date])
        .to eq(earliest_rec)
      expect(interval_attrs[:interval_latest_recommended_date])
        .to eq(latest_rec)
    end
    %w(
      interval_absolute_min_date interval_min_date
      interval_earliest_recommended_date interval_latest_recommended_date
    ).each do |interval_attribute|
      it "creates a hash with the attribute #{interval_attribute}" do
        interval_attrs = test_object.create_interval_attributes(
          test_interval,
          test_aars[0].date_administered
        )
        abr_attribute = interval_attribute.split('_')[0...-1].join('_')
        interval_time_string = test_interval.send(abr_attribute)
        interval_date = test_object.create_patient_age_date(
          interval_time_string, test_aars[0].date_administered
        )
        expect(interval_attrs[interval_attribute.to_sym])
          .to eq(interval_date)
        expect(interval_attrs[interval_attribute.to_sym].class.name)
          .to eq('Date')
      end
    end
    describe 'default values' do
      it 'sets default value for interval_min_date' do
        test_interval.interval_min = nil
        interval_attrs = test_object.create_interval_attributes(
          test_interval,
          test_aars[0].date_administered
        )
        expect(
          interval_attrs[:interval_min_date]
        ).to eq('01/01/1900'.to_date)
      end
      it 'sets default value for interval_absolute_min_date' do
        test_interval.interval_absolute_min = nil
        interval_attrs = test_object.create_interval_attributes(
          test_interval,
          test_aars[0].date_administered
        )
        expect(interval_attrs[:interval_absolute_min_date])
          .to eq('01/01/1900'.to_date)
      end
    end
  end

  describe '#evaluate_interval_attrs' do
    let(:valid_interval_attrs) do
      {
        interval_absolute_min_date: 8.weeks.ago.to_date,
        interval_min_date: 6.weeks.ago.to_date,
        interval_earliest_recommended_date: 5.weeks.ago.to_date,
        interval_latest_recommended_date: 2.weeks.ago.to_date
      }
    end
    it 'returns a hash without \'date\' in the key names' do
      second_dose_date = 6.weeks.ago.to_date
      interval_eval = test_object.evaluate_interval_attrs(
        valid_interval_attrs,
        second_dose_date
      )
      expect(interval_eval.class).to eq(Hash)
      interval_eval.each do |key, _value|
        expect(key.to_s.include?('_date')).to eq(false)
      end
    end
    describe 'for each minimum interval attribute' do
      second_dose_date = 6.weeks.ago.to_date
      attribute_options = {
        before_the_dose_date: [8.weeks.ago.to_date, true],
        after_the_dose_date: [4.weeks.ago.to_date, false],
        nil: [nil, nil]
      }
      %w(
        interval_absolute_min_date
        interval_min_date
        interval_earliest_recommended_date
      ).each do |attribute|
        attribute_options.each do |descriptor, value|
          descriptor_string = "returns #{value[1]} when the #{attribute}"\
                              " attribute is #{descriptor}"
          it descriptor_string do
            valid_interval_attrs[attribute.to_sym] = value[0]
            eval_hash = test_object.evaluate_interval_attrs(
              valid_interval_attrs,
              second_dose_date
            )
            result_key = attribute.split('_')[0..-2].join('_').to_sym
            expect(eval_hash[result_key]).to eq(value[1])
          end
        end
      end
    end
    describe 'for each max interval attribute' do
      second_dose_date = 3.weeks.ago.to_date
      attribute_options = {
        before_the_dose_date: [4.weeks.ago.to_date, false],
        after_the_dose_date: [2.weeks.ago.to_date, true],
        nil: [nil, nil]
      }
      %w(
        interval_latest_recommended_date
      ).each do |attribute|
        attribute_options.each do |descriptor, value|
          descriptor_string = "returns #{value[1]} when the #{attribute}"\
                              " attribute is #{descriptor}"
          it descriptor_string do
            valid_interval_attrs[attribute.to_sym] = value[0]
            eval_hash = test_object.evaluate_interval_attrs(
              valid_interval_attrs,
              second_dose_date
            )
            result_key = attribute.split('_')[0..-2].join('_').to_sym
            expect(eval_hash[result_key]).to eq(value[1])
          end
        end
      end
    end
  end

  describe '#get_interval_status' do
    it 'returns not_valid, too_soon for interval_absolute_min_date false' do
      prev_status_hash = nil
      interval_eval_hash = {
        interval_absolute_min: false,
        interval_min: false,
        interval_earliest_recommended: false,
        interval_latest_recommended: true
      }
      expected_result = { evaluation_status: 'not_valid',
                          evaluated: 'interval',
                          details: 'too_soon' }
      expect(
        test_object.get_interval_status(interval_eval_hash,
                                             prev_status_hash)
      ).to eq(expected_result)
    end

    it 'returns not_valid, too_soon for before interval_min and ' \
      'previous not_valid' do
      prev_status_hash = {
        evaluation_status: 'not_valid',
        reason: 'interval',
        details: 'too_soon'
      }
      interval_eval_hash = {
        interval_absolute_min: true,
        interval_min: false,
        interval_earliest_recommended: false,
        interval_latest_recommended: true
      }
      expected_result = { evaluation_status: 'not_valid',
                          evaluated: 'interval',
                          details: 'too_soon' }
      expect(
        test_object.get_interval_status(interval_eval_hash,
                                             prev_status_hash)
      ).to eq(expected_result)
    end

    it 'returns valid, grace_period for before interval_min ' \
      'and previous valid' do
      prev_status_hash = {
        evaluation_status: 'valid',
        reason: 'grace_period'
      }
      interval_eval_hash = {
        interval_absolute_min: true,
        interval_min: false,
        interval_earliest_recommended: false,
        interval_latest_recommended: true
      }
      expected_result = { evaluation_status: 'valid',
                          evaluated: 'interval',
                          details: 'grace_period' }
      expect(
        test_object.get_interval_status(interval_eval_hash,
                                             prev_status_hash)
      ).to eq(expected_result)
    end
    it 'returns valid, grace_period for before interval_min ' \
      'yet first dose' do
      prev_status_hash = nil
      interval_eval_hash = {
        interval_absolute_min: true,
        interval_min: false,
        interval_earliest_recommended: false,
        interval_latest_recommended: true
      }
      expected_result = { evaluation_status: 'valid',
                          evaluated: 'interval',
                          details: 'grace_period' }
      expect(
        test_object.get_interval_status(interval_eval_hash,
                                             prev_status_hash)
      ).to eq(expected_result)
    end
    it 'returns valid for after interval_min' do
      prev_status_hash = nil
      interval_eval_hash = {
        interval_absolute_min: true,
        interval_min: true,
        interval_earliest_recommended: false,
        interval_latest_recommended: true
      }
      expected_result = { evaluation_status: 'valid',
                          evaluated: 'interval',
                          details: 'on_schedule' }
      expect(
        test_object.get_interval_status(interval_eval_hash,
                                             prev_status_hash)
      ).to eq(expected_result)
    end
  end
  describe '#evaluate_interval' do
    it 'takes a interval_object with date_of_dose, previous_dose_date, ' \
       'previous_dose_status_hash and returns a status hash' do
        interval_object    = FactoryGirl.create(:interval)
        previous_dose_date = 1.year.ago.to_date
        date_of_dose       = (1.year.ago + 9.weeks).to_date
        interval_object.interval_absolute_min         = '5 weeks - 4 days'
        interval_object.interval_min                  = '5 weeks'
        interval_object.interval_earliest_recommended = '9 weeks'
        interval_object.interval_latest_recommended   = '14 weeks'
        evaluation_hash = test_object.evaluate_interval(
          interval_object,
          date_of_dose: date_of_dose,
          previous_dose_date: previous_dose_date
        )
        expected_result = {
                            evaluation_status: 'valid',
                            evaluated: 'interval',
                            details: 'on_schedule'
                          }
        expect(evaluation_hash).to eq(expected_result)
    end
    it 'returns not_valid for not_valid interval between doses' do
        interval_object    = FactoryGirl.create(:interval)
        previous_dose_date = 1.year.ago.to_date
        date_of_dose       = (1.year.ago + 4.weeks).to_date
        interval_object.interval_absolute_min         = '5 weeks - 4 days'
        interval_object.interval_min                  = '5 weeks'
        interval_object.interval_earliest_recommended = '9 weeks'
        interval_object.interval_latest_recommended   = '14 weeks'
        evaluation_hash = test_object.evaluate_interval(
          interval_object,
          date_of_dose: date_of_dose,
          previous_dose_date: previous_dose_date
        )
        expected_result = {
                            evaluation_status: 'not_valid',
                            evaluated: 'interval',
                            details: 'too_soon'
                          }
        expect(evaluation_hash).to eq(expected_result)
    end
  end
end
