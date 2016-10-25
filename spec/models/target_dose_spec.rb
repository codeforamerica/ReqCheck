require 'rails_helper'

RSpec.describe TargetDose, type: :model do
  include AntigenImporterSpecHelper

  describe 'validations' do
    # Test patient with two vaccine doses for polio, both should be valid
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

    let(:antigen_series_dose) { FactoryGirl.create(:antigen_series_dose) }

    it 'takes a patient and antigen_series_dose as parameters' do
      expect(
        TargetDose.new(antigen_series_dose: antigen_series_dose,
                       patient: test_patient).class.name
      ).to eq('TargetDose')
    end

    it 'requires a patient object' do
      expect { TargetDose.new(antigen_series_dose: antigen_series_dose) }
        .to raise_exception(ArgumentError)
    end
    it 'requires an antigen_series_dose' do
      expect { TargetDose.new(patient: test_patient) }
        .to raise_exception(ArgumentError)
    end
  end

  describe '.create_target_doses' do
    before(:all) { seed_antigen_xml_polio }
    after(:all) { DatabaseCleaner.clean_with(:truncation) }

    let(:antigen_series) do
      Antigen.find_by(target_disease: 'polio').series.first
    end

    let(:test_patient_series) do
      PatientSeries.new(antigen_series: antigen_series, patient: test_patient)
    end

    it 'maps the patient_series doses and creates a target_dose for each' do
      antigen_series_length = test_patient_series.doses.length
      expect(test_patient_series.target_doses).to eq(nil)

      TargetDose.create_target_doses(patient_series)
      expect(patient_series.target_doses.length).to eq(antigen_series_length)
    end

    it 'creates target_doses' do
      target_doses = TargetDose.create_target_doses(patient_series)
      expect(target_doses.first.class.name).to eq('TargetDose')
    end

    it 'orders them by dose number' do
      target_doses = TargetDose.create_target_doses(patient_series)

      first_target_dose = target_doses[0]
      expect(first_target_dose.dose_number).to eq(1)

      second_target_dose = target_doses[1]
      expect(second_target_dose.dose_number).to eq(2)
    end
  end

  describe 'tests needing the antigen_series database' do
    before(:all) { seed_antigen_xml_polio }
    after(:all) { DatabaseCleaner.clean_with(:truncation) }

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
                     patient: test_patient)
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

    describe '#eligible?' do
      let(:eligible_as_dose) do
        FactoryGirl.create(
          :antigen_series_dose,
          absolute_min_age: '6 weeks - 4 days',
          max_age: '18 years'
        )
      end
      it 'returns true if eligible by absolute_min_age and patient_dob' do
        test_patient = FactoryGirl.create(:patient,
                                          dob: 10.weeks.ago.to_date)
        test_target_dose = TargetDose.new(
          patient: test_patient,
          antigen_series_dose: eligible_as_dose
        )
        expect(test_target_dose.absolute_min_age).to eq('6 weeks - 4 days')
        expect(test_target_dose.eligible?).to eq(true)
      end
      it 'returns false if ineligible by absolute_min_age and patient_dob' do
        test_patient = FactoryGirl.create(:patient,
                                          dob: 3.weeks.ago.to_date)
        test_target_dose = TargetDose.new(
          patient: test_patient,
          antigen_series_dose: eligible_as_dose
        )
        expect(test_target_dose.absolute_min_age).to eq('6 weeks - 4 days')
        expect(test_target_dose.eligible?).to eq(false)
      end
      it 'can handle min_age = nil' do
        test_patient = FactoryGirl.create(:patient,
                                          dob: 16.years.ago.to_date)
        eligible_as_dose.min_age = nil
        test_target_dose = TargetDose.new(
          patient: test_patient,
          antigen_series_dose: eligible_as_dose
        )
        expect(test_target_dose.min_age).to eq(nil)
        expect(test_target_dose.eligible?).to eq(true)
      end
      it 'returns true if eligible by max_age and patient_dob' do
        test_patient = FactoryGirl.create(:patient,
                                          dob: 17.years.ago.to_date)
        test_target_dose = TargetDose.new(
          patient: test_patient,
          antigen_series_dose: eligible_as_dose
        )
        expect(test_target_dose.max_age).to eq('18 years')
        expect(test_target_dose.eligible?).to eq(true)
      end
      it 'returns false if ineligible by max_age and patient_dob' do
        test_patient = FactoryGirl.create(:patient,
                                          dob: 19.years.ago.to_date)
        test_target_dose = TargetDose.new(
          patient: test_patient,
          antigen_series_dose: eligible_as_dose
        )
        expect(test_target_dose.max_age).to eq('18 years')
        expect(test_target_dose.eligible?).to eq(false)
      end
      it 'can handle max_age = nil' do
        test_patient = FactoryGirl.create(:patient,
                                          dob: 16.years.ago.to_date)
        eligible_as_dose.max_age = nil
        test_target_dose = TargetDose.new(
          patient: test_patient,
          antigen_series_dose: eligible_as_dose
        )
        expect(test_target_dose.max_age).to eq(nil)
        expect(test_target_dose.eligible?).to eq(true)
      end
      it 'does not return recurring doses' do
        test_patient = FactoryGirl.create(:patient,
                                          dob: 16.years.ago.to_date)
        eligible_as_dose.min_age        = nil
        eligible_as_dose.max_age        = nil
        eligible_as_dose.recurring_dose = true
        test_target_dose = TargetDose.new(
          patient: test_patient,
          antigen_series_dose: eligible_as_dose
        )
        expect(test_target_dose.recurring_dose).to eq(true)
        expect(test_target_dose.eligible?).to eq(false)
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
        expect(eval_hash[:evaluation_status]).to eq('valid')
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
                       patient: test_patient)
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
                       patient: test_patient)
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

    end
    describe 'implementation of evaluate preferable/allowable vaccines logic' do
      describe '#evaluate_preferable_vaccine' do

      end
    end
    describe 'implementation of evaluate gender logic' do

    end
    describe 'satisfy target dose implementation logic' do
      describe '#satisfy_target_dose' do
      end
    end

    describe 'full evaluation methods' do
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

      let(:antigen_series_dose) do
        FactoryGirl.create(:antigen_series_dose_with_vaccines)
      end

      let(:test_target_dose) do
          TargetDose.new(antigen_series_dose: antigen_series_dose,
                         patient: test_patient)
      end

      describe '#evaluate_satisfy_target_dose' do
        it 'evaluates the antigen_administered_record and returns a status hash' do
          aars = AntigenAdministeredRecord.create_records_from_vaccine_doses(
            test_patient.vaccine_doses
          )
          aar = aars.first

          expected_result = {
            good: 'job'
          }

          result_hash = test_target_dose.evaluate_satisfy_target_dose(
            aar
          )

          expect(result_hash).to eq(expected_result)
        end
      end
      describe '#evaluate_antigen_administered_record' do
        it 'evaluates the antigen_administered_record and returns boolean' do
          aars = AntigenAdministeredRecord.create_records_from_vaccine_doses(
            test_patient.vaccine_doses
          )
          aar = aars.first

          expected_result = {
            good: 'job'
          }

          result = test_target_dose.evaluate_antigen_administered_record(
            aar
          )

          expect(result).to eq(true)
        end
        it 'sets the satisfied, status_hash and antigen_administered_record' \
           ' attributes on the target dose' do
          aars = AntigenAdministeredRecord.create_records_from_vaccine_doses(
            test_patient.vaccine_doses
          )
          aar = aars.first

          expected_result = {
            good: 'job'
          }

          expect(test_target_dose.satisfied).to eq(nil)
          expect(test_target_dose.status_hash).to eq(nil)
          expect(test_target_dose.antigen_administered_record).to eq(nil)

          test_target_dose.evaluate_antigen_administered_record(
            aar
          )

          expect(test_target_dose.satisfied).to eq(true)
          expect(test_target_dose.status_hash.class.name).to eq('Hash')
          expect(test_target_dose.antigen_administered_record).to eq(aar)
        end
      end

    end

  end
end
