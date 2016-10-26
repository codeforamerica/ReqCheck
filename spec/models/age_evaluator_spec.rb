require 'rails_helper'

RSpec.describe AgeEvaluator, type: :model do
  include AntigenImporterSpecHelper

  before(:all) { seed_antigen_xml_polio }
  after(:all) { DatabaseCleaner.clean_with(:truncation) }

  let(:default_patient) { FactoryGirl.create(:patient) }

  let(:default_antigen_series) do
    AntigenSeries.where(preference_number: 1
      ).joins('INNER JOIN "antigens" ON "antigens"."id" ' \
              '= "antigen_series"."antigen_id"'
      ).where(antigens: { target_disease: 'polio' }).first
  end

  let(:default_patient_series) do
    PatientSeries.new(patient: default_patient,
                      antigen_series: default_antigen_series)
  end

  let(:default_target_dose) do
    default_patient_series.target_doses.first
  end

  describe '#build_attributes' do
    # Consistent dob for all tests
    let(:patient_dob) { 10.weeks.ago }

    # Set the target dose patient dob before each test
    before(:each) do
      default_target_dose.patient.dob = patient_dob
    end

    context 'with minimum age attributes' do
      it 'builds an absolute_min_age_date' do
        expected_date = (patient_dob + 6.weeks).to_date
        default_target_dose.antigen_series_dose.absolute_min_age = '6 weeks'

        age_evaluator = AgeEvaluator.new(default_target_dose)

        attributes = age_evaluator.build_attributes
        expect(attributes[:absolute_min_age_date]).to eq(expected_date)
      end
      it 'builds a min_age_date' do
        expected_date = (patient_dob + 8.weeks).to_date
        default_target_dose.antigen_series_dose.min_age = '8 weeks'

        age_evaluator = AgeEvaluator.new(default_target_dose)

        attributes = age_evaluator.build_attributes
        expect(attributes[:min_age_date]).to eq(expected_date)
      end
      it 'builds an earliest_recommended_age_date' do
        expected_date = (patient_dob + 8.weeks).to_date
        default_target_dose
          .antigen_series_dose
          .earliest_recommended_age = '8 weeks'

        age_evaluator = AgeEvaluator.new(default_target_dose)

        attributes = age_evaluator.build_attributes
        expect(attributes[:earliest_recommended_age_date]).to eq(expected_date)
      end
    end
    context 'with max age attributes' do
      it 'builds a latest_recommended_age_date' do
        expected_date = (patient_dob + 8.weeks).to_date
        default_target_dose
          .antigen_series_dose
          .latest_recommended_age = '8 weeks'

        age_evaluator = AgeEvaluator.new(default_target_dose)

        attributes = age_evaluator.build_attributes
        expect(attributes[:latest_recommended_age_date]).to eq(expected_date)
      end
      it 'builds a max_age_date' do
        expected_date = (patient_dob + 8.weeks).to_date
        default_target_dose.antigen_series_dose.max_age = '8 weeks'

        age_evaluator = AgeEvaluator.new(default_target_dose)

        attributes = age_evaluator.build_attributes
        expect(attributes[:max_age_date]).to eq(expected_date)
      end
    end
    describe 'default values' do
      # As described on page 38 on CDC logic specs
      # 'http://www.cdc.gov/vaccines/programs/iis/interop-proj/'\
      #   'downloads/logic-spec-acip-rec.pdf'

      it 'sets default value for max_age_date' do
        expected_date = '12/31/2999'.to_date
        default_target_dose.antigen_series_dose.max_age = nil

        age_evaluator = AgeEvaluator.new(default_target_dose)

        attributes = age_evaluator.build_attributes
        expect(attributes[:max_age_date]).to eq(expected_date)
      end
      it 'sets default value for min_age_date' do
        expected_date = '01/01/1900'.to_date
        default_target_dose.antigen_series_dose.min_age = nil

        age_evaluator = AgeEvaluator.new(default_target_dose)

        attributes = age_evaluator.build_attributes
        expect(attributes[:min_age_date]).to eq(expected_date)
      end
      it 'sets default value for absolute_min_age_date' do
        expected_date = '01/01/1900'.to_date
        default_target_dose.antigen_series_dose.absolute_min_age = nil

        age_evaluator = AgeEvaluator.new(default_target_dose)

        attributes = age_evaluator.build_attributes
        expect(attributes[:absolute_min_age_date]).to eq(expected_date)
      end
    end
  end

end
