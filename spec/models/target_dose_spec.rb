require 'rails_helper'

RSpec.describe TargetDose, type: :model do
  describe 'validations' do
    # Test patient with two vaccine doses for polio, both should be valid
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

    let(:antigen_series_dose) { FactoryGirl.create(:antigen_series_dose) }
    it 'takes a patient and antigen_series_dose as parameters' do
      expect(
        TargetDose.new(antigen_series_dose: antigen_series_dose,
                       patient_dob: test_patient.dob).class.name
      ).to eq('TargetDose')
    end

    it 'requires a patient object' do
      expect { TargetDose.new(antigen_series_dose: antigen_series_dose) }
        .to raise_exception(ArgumentError)
    end
    it 'requires an antigen_series_dose' do
      expect { TargetDose.new(patient_dob: test_patient.dob) }
        .to raise_exception(ArgumentError)
    end
  end

  describe 'tests needing the antigen_series database' do
    before(:all) { FactoryGirl.create(:seed_antigen_xml_polio) }
    after(:all) { DatabaseCleaner.clean_with(:truncation) }

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

    let(:as_dose) do
      AntigenSeriesDose
        .joins(:antigen_series)
        .joins(
          'INNER JOIN "antigens" ON "antigens"."id" ' \
          '= "antigen_series"."antigen_id"'
        ).where(antigens: { target_disease: 'polio' }).first
    end
    let(:test_target_dose) do
      TargetDose.new(antigen_series_dose: as_dose,
                     patient_dob: test_patient.dob)
    end

    describe 'target dose attributes from the antigen_series_dose' do
      dose_attributes = %w(
        dose_number absolute_min_age min_age earliest_recommended_age
        latest_recommended_age max_age required_gender recurring_dose
        intervals dose_vaccines preferable_vaccines allowable_vaccines
      )
      dose_attributes.each do |dose_attribute|
        it "has the attribute #{dose_attribute}" do
          expect(test_target_dose.antigen_series_dose).not_to eq(nil)
          expect(test_target_dose.send(dose_attribute))
            .to eq(as_dose.send(dose_attribute))
        end
      end

      it 'has a dose number' do
        expect(test_target_dose.dose_number).to eq(1)
      end
    end

    xdescribe '#age_eligible?' do
      it 'sets @eligible? attribute to true if target_dose is eligible' do
        expect(test_target_dose.eligible).to eq(nil)
        expect(test_target_dose.min_age).to eq('6 weeks')
        test_target_dose.age_eligible?(8.weeks.ago.to_date)
        expect(test_target_dose.eligible).to eq(true)
      end
      it 'sets @eligible? attribute to false if target_dose is ineligible' do
        expect(test_target_dose.eligible).to eq(nil)
        expect(test_target_dose.min_age).to eq('6 weeks')
        test_target_dose.age_eligible?(1.day.ago.to_date)
        expect(test_target_dose.eligible).to eq(false)
      end
      it 'checks agains max age' do
        expect(test_target_dose.max_age).to eq('18 years')
        expect(test_target_dose.eligible).to eq(nil)
        test_target_dose.age_eligible?(19.years.ago.to_date)
        expect(test_target_dose.eligible).to eq(false)
      end
      it 'can handle max age being nil' do
        test_target_dose.antigen_series_dose.max_age = nil
        expect(test_target_dose.max_age).to eq(nil)
        expect(test_target_dose.eligible).to eq(nil)
        test_target_dose.age_eligible?(19.years.ago.to_date)
        expect(test_target_dose.eligible).to eq(true)
      end
    end

    describe '#evaluate_antigen_administered_record' do
      let(:aar) do
        AntigenAdministeredRecord.create_records_from_vaccine_doses(
          test_patient.vaccine_doses
        ).first
      end
      # expect(test_target_dose.evaluate_antigen_administered_record()

      # 'Extraneous'
      # 'Not Valid'
      # 'Valid'
      # 'Sub-standard'

      xit 'returns an evaluation hash' do
        eval_hash = test_target_dose.evaluate_antigen_administered_record(aar)
        expect(eval_hash[:evaluation_status]).to eq('Valid')
        expect(eval_hash[:target_dose_satisfied]).to eq(true)
      end
    end

    describe 'evaluating the conditional skip' do
      let(:target_dose_w_cond_skip) do
        as_dose_w_cond_skip = AntigenSeriesDose
                              .joins(:conditional_skip)
                              .joins(:antigen_series)
                              .joins(
                                'INNER JOIN "antigens" ON "antigens"."id"'\
                                ' = "antigen_series"."antigen_id"'
                              ).where(antigens: { target_disease: 'polio' })
                              .where(
                                'conditional_skips.antigen_series_dose_id'\
                                ' IS NOT NULL'
                              ).first
        TargetDose.new(antigen_series_dose: as_dose_w_cond_skip,
                       patient_dob: test_patient.dob)
      end
      let(:target_dose_no_cond_skip) do
        as_dose_no_cond_skip = AntigenSeriesDose
                               .joins(:antigen_series)
                               .joins(
                                 'INNER JOIN "antigens" ON "antigens"."id" = '\
                                 '"antigen_series"."antigen_id"'
                               ).where(antigens: { target_disease: 'polio' })
                               .first
        TargetDose.new(antigen_series_dose: as_dose_no_cond_skip,
                       patient_dob: test_patient.dob)
      end

      describe '#has_conditional_skip?' do
        it 'returns true if there is a conditional skip' do
          expect(target_dose_w_cond_skip.has_conditional_skip?).to be(true)
        end
        it 'returns false if there is no conditional skip' do
          expect(target_dose_no_cond_skip.has_conditional_skip?).to be(false)
        end
      end
    end

    describe 'implementation of interval logic' do
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

      let(:test_target_dose) do
        TargetDose.new(antigen_series_dose: as_dose_w_interval,
                       patient_dob: test_patient.dob)
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

      describe '#evaluate_interval' do
        # This logic is defined on page 39 of the CDC logic spec to evaluate the
        # interval (or intervals) between two antigen_administered_records
        #
        # HOW/WHAT IS ALLOWABLE INTERVAL EFFECTED?
        #

        it 'takes two records and returns valid if the interval is valid' do
          expect(as_dose_w_interval.intervals.first.interval_absolute_min)
            .to eq('4 weeks - 4 days')
          interval_eval = test_target_dose.evaluate_interval(test_aars[0],
                                                             test_aars[1])
          expect(interval_eval).to eq([{ status: 'valid', reason: 'whatever' }])
        end
      end

      describe '#create_interval_date_attributes' do
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
          interval_attrs = test_target_dose.create_interval_date_attributes(
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
            interval_attrs = test_target_dose.create_interval_date_attributes(
              test_interval,
              test_aars[0].date_administered
            )
            abr_attribute = interval_attribute.split('_')[0...-1].join('_')
            interval_time_string = test_interval.send(abr_attribute)
            interval_date = test_target_dose.create_patient_age_date(
              interval_time_string, test_aars[0].date_administered
            )
            expect(interval_attrs[interval_attribute.to_sym])
              .to eq(interval_date)
            expect(interval_attrs[interval_attribute.to_sym].class.name)
              .to eq('Date')
          end
        end
        describe 'default values' do
          # As described on page 38 on CDC logic specs
          # 'http://www.cdc.gov/vaccines/programs/iis/interop-proj/'\
          #   'downloads/logic-spec-acip-rec.pdf'
          it 'sets default value for interval_min_date' do
            test_interval.interval_min = nil
            interval_attrs = test_target_dose.create_interval_date_attributes(
              test_interval,
              test_aars[0].date_administered
            )
            expect(
              interval_attrs[:interval_min_date]
            ).to eq('01/01/1900'.to_date)
          end
          it 'sets default value for interval_absolute_min_date' do
            test_interval.interval_absolute_min = nil
            interval_attrs = test_target_dose.create_interval_date_attributes(
              test_interval,
              test_aars[0].date_administered
            )
            expect(interval_attrs[:interval_absolute_min_date])
              .to eq('01/01/1900'.to_date)
          end
        end
      end

      describe '#evaluate_interval_dates' do
        let(:valid_interval_attrs) do
          {
            interval_absolute_min_date: 8.weeks.ago.to_date,
            interval_min_date: 6.weeks.ago.to_date,
            interval_earliest_recommended_date: 5.weeks.ago.to_date,
            interval_latest_recommended_date: 2.weeks.ago.to_date
          }
        end
        it 'returns a hash with \'date\' in the key names' do
          second_dose_date = 6.weeks.ago.to_date
          interval_eval = test_target_dose.evaluate_interval_dates(
            valid_interval_attrs,
            second_dose_date
          )
          expect(interval_eval.class).to eq(Hash)
          interval_eval.each do |key, _value|
            expect(key.to_s.include?('_date')).to eq(true)
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
                eval_hash = test_target_dose.evaluate_interval_dates(
                  valid_interval_attrs,
                  second_dose_date
                )
                expect(eval_hash[attribute.to_sym]).to eq(value[1])
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
                eval_hash = test_target_dose.evaluate_interval_dates(
                  valid_interval_attrs,
                  second_dose_date
                )
                expect(eval_hash[attribute.to_sym]).to eq(value[1])
              end
            end
          end
        end
      end

      describe '#get_interval_status' do
        # This logic is defined on page 39 of the CDC logic spec
        it 'returns invalid, too_soon for interval_absolute_min_date false' do
          prev_status_hash = nil
          interval_eval_hash = {
            interval_absolute_min: false,
            interval_min: false,
            interval_earliest_recommended: false,
            interval_latest_recommended: true
          }
          expected_result = { status: 'invalid',
                              reason: 'interval',
                              details: 'too_soon' }
          expect(
            test_target_dose.get_interval_status(interval_eval_hash,
                                                 prev_status_hash)
          ).to eq(expected_result)
        end

        it 'returns invalid, too_soon for before interval_min and ' \
          'previous invalid' do
          prev_status_hash = {
            status: 'invalid',
            reason: 'interval',
            details: 'too_soon'
          }
          interval_eval_hash = {
            interval_absolute_min: true,
            interval_min: false,
            interval_earliest_recommended: false,
            interval_latest_recommended: true
          }
          expected_result = { status: 'invalid',
                              reason: 'interval',
                              details: 'too_soon' }
          expect(
            test_target_dose.get_interval_status(interval_eval_hash,
                                                 prev_status_hash)
          ).to eq(expected_result)
        end

        it 'returns valid, grace_period for before interval_min ' \
          'and previous valid' do
          prev_status_hash = {
            status: 'valid',
            reason: 'grace_period'
          }
          interval_eval_hash = {
            interval_absolute_min: true,
            interval_min: false,
            interval_earliest_recommended: false,
            interval_latest_recommended: true
          }
          expected_result = { status: 'valid',
                              reason: 'grace_period' }
          expect(
            test_target_dose.get_interval_status(interval_eval_hash,
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
          expected_result = { status: 'valid',
                              reason: 'grace_period' }
          expect(
            test_target_dose.get_interval_status(interval_eval_hash,
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
          expected_result = { status: 'valid',
                              reason: 'on_schedule' }
          expect(
            test_target_dose.get_interval_status(interval_eval_hash,
                                                 prev_status_hash)
          ).to eq(expected_result)
        end
      end
    end
    describe 'implementation of evaluate preferable/allowable vaccines logic' do
      describe '#evaluate_preferable_vaccine' do

      end
    end
    describe 'implementation of evaluate gender logic' do
      let(:as_dose) { FactoryGirl.create(:antigen_series_dose) }
      describe '#evaluate_gender' do
        # This logic is defined on page 48 of the CDC logic spec to evaluate the
        # preferable vaccines and if they have been used (or if allowable has
        # been used)
      end

      describe '#create_gender_attributes' do
        it 'returns a hash with required_gender key and array value' do
          gender_attrs = test_target_dose.create_gender_attributes(as_dose)
          expect(gender_attrs[:required_gender]).to eq([])
        end
        it 'returns [\'female\'] when Female included' do
          as_dose.required_gender = ['Female']

          gender_attrs = test_target_dose.create_gender_attributes(as_dose)
          expect(gender_attrs[:required_gender]).to eq(['female'])
        end
        it 'returns [\'male\'] when Male included' do
          as_dose.required_gender = ['Male']

          gender_attrs = test_target_dose.create_gender_attributes(as_dose)
          expect(gender_attrs[:required_gender]).to eq(['male'])
        end
        it 'returns unknown when Unknown' do
          as_dose.required_gender = ['Unknown']

          gender_attrs = test_target_dose.create_gender_attributes(as_dose)
          expect(gender_attrs[:required_gender]).to eq(['unknown'])
        end
        it 'returns multiple values with multiple required genders ' do
          as_dose.required_gender = %w(Unknown Female)

          gender_attrs = test_target_dose.create_gender_attributes(as_dose)
          expect(gender_attrs[:required_gender]).to eq(%w(unknown female))
        end
        it 'returns empty array when none specified' do
          expect(as_dose.required_gender).to eq([])

          gender_attrs = test_target_dose.create_gender_attributes(as_dose)
          expect(gender_attrs[:required_gender]).to eq([])
        end
      end

      describe '#evaluate_gender_attributes' do
        describe 'with different combinations' do
          context 'with a female patient' do
            it 'returns true if the required_gender includes female' do
              gender_attrs = { required_gender: %w(female unknown) }
              eval_hash = test_target_dose.evaluate_gender_attributes(
                gender_attrs, 'female'
              )
              expect(eval_hash[:required_gender_valid]).to eq(true)
            end
            it 'returns true if the required_gender is only female' do
              gender_attrs = { required_gender: ['female'] }
              eval_hash = test_target_dose.evaluate_gender_attributes(
                gender_attrs, 'female'
              )
              expect(eval_hash[:required_gender_valid]).to eq(true)
            end
            it 'returns false if the required_gender doesn\'t include female' do
              gender_attrs = { required_gender: %w(male unknown) }
              eval_hash = test_target_dose.evaluate_gender_attributes(
                gender_attrs, 'female'
              )
              expect(eval_hash[:required_gender_valid]).to eq(false)
            end
            it 'returns true if the required_gender is empty' do
              gender_attrs = { required_gender: [] }
              eval_hash = test_target_dose.evaluate_gender_attributes(
                gender_attrs, 'female'
              )
              expect(eval_hash[:required_gender_valid]).to eq(true)
            end
          end
          context 'with a male patient' do
            it 'returns true if the required_gender includes male' do
              gender_attrs = { required_gender: %w(male unknown) }
              eval_hash = test_target_dose.evaluate_gender_attributes(
                gender_attrs, 'male'
              )
              expect(eval_hash[:required_gender_valid]).to eq(true)
            end
            it 'returns true if the required_gender is only male' do
              gender_attrs = { required_gender: ['male'] }
              eval_hash = test_target_dose.evaluate_gender_attributes(
                gender_attrs, 'male'
              )
              expect(eval_hash[:required_gender_valid]).to eq(true)
            end
            it 'returns false if the required_gender doesn\'t include male' do
              gender_attrs = { required_gender: %w(female unknown) }
              eval_hash = test_target_dose.evaluate_gender_attributes(
                gender_attrs, 'male'
              )
              expect(eval_hash[:required_gender_valid]).to eq(false)
            end
            it 'returns true if the required_gender is empty' do
              gender_attrs = { required_gender: [] }
              eval_hash = test_target_dose.evaluate_gender_attributes(
                gender_attrs, 'male'
              )
              expect(eval_hash[:required_gender_valid]).to eq(true)
            end
          end
          context 'with a patient with an unidentified gender' do
            it 'returns true if the required_gender includes unknown' do
              gender_attrs = { required_gender: %w(male unknown) }
              eval_hash = test_target_dose.evaluate_gender_attributes(
                gender_attrs, nil
              )
              expect(eval_hash[:required_gender_valid]).to eq(true)
            end
            it 'returns false if the required_gender is only male' do
              gender_attrs = { required_gender: ['male'] }
              eval_hash = test_target_dose.evaluate_gender_attributes(
                gender_attrs, nil
              )
              expect(eval_hash[:required_gender_valid]).to eq(false)
            end
            it 'returns false if the required_gender is only female' do
              gender_attrs = { required_gender: ['female'] }
              eval_hash = test_target_dose.evaluate_gender_attributes(
                gender_attrs, nil
              )
              expect(eval_hash[:required_gender_valid]).to eq(false)
            end
            it 'returns true if the required_gender is empty' do
              gender_attrs = { required_gender: [] }
              eval_hash = test_target_dose.evaluate_gender_attributes(
                gender_attrs, nil
              )
              expect(eval_hash[:required_gender_valid]).to eq(true)
            end
          end
        end
      end

      describe '#get_gender_status' do
        # This logic is defined on page 53 of the CDC logic spec
        it 'returns valid, gender, for required_gender_valid true' do
          gender_eval_hash = { required_gender_valid: true }
          expected_result = { status: 'valid',
                              reason: 'gender' }
          expect(test_target_dose.get_gender_status(gender_eval_hash))
            .to eq(expected_result)
        end

        it 'returns invalid, gender, for required_gender_valid true' do
          gender_eval_hash = { required_gender_valid: false }
          expected_result = { status: 'invalid',
                              reason: 'gender' }
          expect(test_target_dose.get_gender_status(gender_eval_hash))
            .to eq(expected_result)
        end
      end
    end
    describe 'satisfy target dose implementation logic' do
      describe '#satisfy_target_dose' do
      end
    end
  end
end
