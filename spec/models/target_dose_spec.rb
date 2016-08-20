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
    before(:all) { FactoryGirl.create(:seed_antigen_xml) }
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
          'INNER JOIN "antigens" ON "antigens"."id" = "antigen_series"."antigen_id"'
        ).where(antigens: { target_disease: 'polio' }).first
    end
    let(:test_target_dose) do
      TargetDose.new(antigen_series_dose: as_dose, patient_dob: test_patient.dob)
    end

    describe 'target dose attributes from the antigen_series_dose' do
      dose_attributes = %w(
        dose_number absolute_min_age min_age earliest_recommended_age
        latest_recommended_age max_age allowable_interval_type
        allowable_interval_absolute_min required_gender recurring_dose
        intervals
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

    describe '#create_age_attributes' do
      %w(absolute_min_age_date min_age_date earliest_recommended_age_date
         latest_recommended_age_date max_age_date).each do |age_attribute|
        it "sets the target_dose attribute #{age_attribute}" do
          age_attrs = test_target_dose.create_age_attributes(
            as_dose,
            test_patient.dob
          )
          as_dose_attribute  = age_attribute.split('_')[0...-1].join('_')
          as_dose_age_string = as_dose.send(as_dose_attribute)
          age_date = test_target_dose.create_patient_age_date(
            as_dose_age_string, test_patient.dob
          )
          expect(age_attrs[age_attribute.to_sym]).to eq(age_date)
          expect(age_attrs[age_attribute.to_sym].class.name).to eq('Date')
        end
      end
      describe 'default values' do
        # As described on page 38 on CDC logic specs
        # 'http://www.cdc.gov/vaccines/programs/iis/interop-proj/'\
        #   'downloads/logic-spec-acip-rec.pdf'

        it 'sets default value for max_age_date' do
          as_dose.max_age = nil
          age_attrs = test_target_dose.create_age_attributes(
            as_dose,
            test_patient.dob
          )
          expect(age_attrs[:max_age_date]).to eq('12/31/2999'.to_date)
        end
        it 'sets default value for min_age_date' do
          as_dose.min_age = nil
          age_attrs = test_target_dose.create_age_attributes(
            as_dose,
            test_patient.dob
          )
          expect(age_attrs[:min_age_date]).to eq('01/01/1900'.to_date)
        end
        it 'sets default value for absolute_min_age_date' do
          as_dose.absolute_min_age = nil
          age_attrs = test_target_dose.create_age_attributes(
            as_dose,
            test_patient.dob
          )
          expect(age_attrs[:absolute_min_age_date]).to eq('01/01/1900'.to_date)
        end
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
                              .joins('INNER JOIN "antigens" ON "antigens"."id" = "antigen_series"."antigen_id"')
                              .where(antigens: { target_disease: 'polio' })
                              .where('conditional_skips.antigen_series_dose_id IS NOT NULL')
                              .first
        TargetDose.new(antigen_series_dose: as_dose_w_cond_skip,
                       patient_dob: test_patient.dob)
      end
      let(:target_dose_no_cond_skip) do
        as_dose_no_cond_skip = AntigenSeriesDose
                               .joins(:antigen_series)
                               .joins('INNER JOIN "antigens" ON "antigens"."id" = "antigen_series"."antigen_id"')
                               .where(antigens: { target_disease: 'polio' })
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

      xdescribe '#evalutate_conditional_skip' do
        # it ''
      end
    end

    describe '#evaluate_dose_age' do
      let(:valid_age_attrs) do
        {
          absolute_min_age_date: 12.months.ago.to_date,
          min_age_date: 10.months.ago.to_date,
          earliest_recommended_age_date: 8.months.ago.to_date,
          latest_recommended_age_date: 2.months.ago.to_date,
          max_age_date: 1.month.ago.to_date
        }
      end
      it 'returns a hash' do
        dose_date = 6.months.ago.to_date
        expect(
          test_target_dose.evaluate_dose_age(valid_age_attrs, dose_date).class
        ).to eq(Hash)
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
              descriptor_string = "returns #{value[1]} when the #{attribute}"\
                                  " attribute is #{descriptor}"
              it descriptor_string do
                valid_age_attrs[attribute.to_sym] = value[0]
                eval_hash = test_target_dose.evaluate_dose_age(valid_age_attrs,
                                                               dose_date)
                expect(eval_hash[attribute.to_sym]).to eq(value[1])
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
                eval_hash = test_target_dose.evaluate_dose_age(valid_age_attrs,
                                                               dose_date)
                expect(eval_hash[attribute.to_sym]).to eq(value[1])
              end
            end
          end
      end
    end

    describe '#get_age_status' do
      # This logic is defined on page 38 of the CDC logic spec
      it 'returns invalid, too young for absolute_min_age false' do
        prev_status_hash = nil
        age_eval_hash = {
          absolute_min_age: false,
          min_age: false,
          earliest_recommended_age: false,
          latest_recommended_age: true,
          max_age: true
        }
        expected_result = { status: 'invalid',
                            reason: 'age',
                            details: 'too_young',
                            record: as_dose }
        expect(
          test_target_dose.get_age_status(age_eval_hash,
                                          as_dose,
                                          prev_status_hash)
        ).to eq(expected_result)
      end

      it 'returns invalid, too young for before min_age and previous invalid' do
        prev_status_hash = {
          status: 'invalid',
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
        expected_result = { status: 'invalid',
                            reason: 'age',
                            details: 'too_young',
                            record: as_dose }
        expect(
          test_target_dose.get_age_status(age_eval_hash,
                                          as_dose,
                                          prev_status_hash)
        ).to eq(expected_result)
      end

      it 'returns valid, grace_period for before min_age and previous valid' do
        prev_status_hash = {
          status: 'valid',
          reason: 'grace_period'
        }
        age_eval_hash = {
          absolute_min_age: true,
          min_age: false,
          earliest_recommended_age: false,
          latest_recommended_age: true,
          max_age: true
        }
        expected_result = { status: 'valid',
                            reason: 'grace_period',
                            record: as_dose }
        expect(
          test_target_dose.get_age_status(age_eval_hash,
                                          as_dose,
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
        expected_result = { status: 'valid',
                            reason: 'grace_period',
                            record: as_dose }
        expect(
          test_target_dose.get_age_status(age_eval_hash,
                                          as_dose,
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
        expected_result = { status: 'valid',
                            reason: 'on_schedule',
                            record: as_dose }
        expect(
          test_target_dose.get_age_status(age_eval_hash,
                                          as_dose,
                                          prev_status_hash)
        ).to eq(expected_result)
      end
      it 'returns invalid, too_old for after max_age' do
        prev_status_hash = nil
        age_eval_hash = {
          absolute_min_age: true,
          min_age: true,
          earliest_recommended_age: true,
          latest_recommended_age: false,
          max_age: false
        }
        expected_result = { status: 'invalid',
                            reason: 'age',
                            details: 'too_old',
                            record: as_dose }
        expect(
          test_target_dose.get_age_status(age_eval_hash,
                                          as_dose,
                                          prev_status_hash)
        ).to eq(expected_result)
      end
    end

  # describe '#required_for_patient' do
  #   let(:test_patient) { FactoryGirl.create(:patient_profile, dob: 2.years.ago).patient }
  #   let(:antigen_series_dose) { FactoryGirl.create(:antigen_series_dose) }

  #   it 'checks if the target_dose is required for the patient and returns boolean' do
  #     target_dose = TargetDose.new(patient_dob: test_patient.dob, antigen_series_dose: antigen_series_dose)
  #     expect(target_dose.required_for_patient).to eq(true)
  #   end
  #   it 'returns false if the antigen_series_dose dose not satisfy the ' do
  #     target_dose = TargetDose.new(patient_dob: test_patient.dob, antigen_series_dose: antigen_series_dose)
  #     expect(target_dose.required_for_patient).to eq(true)
  #   end
  # end
  end
end
