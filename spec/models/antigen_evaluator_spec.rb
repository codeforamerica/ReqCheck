require 'rails_helper'

RSpec.describe AntigenEvaluator, type: :model do
  include AntigenImporterSpecHelper
  include PatientSpecHelper

  before(:all) { seed_antigen_xml_polio }
  after(:all) { DatabaseCleaner.clean_with(:truncation) }

  let(:test_antigen) { Antigen.find_by(target_disease: 'polio') }
  let(:test_patient) { FactoryGirl.create(:patient) }

  let(:test_vaccine_doses) do
    valid_dates = create_valid_dates(test_patient.dob)
    create_patient_vaccines(test_patient, valid_dates)
  end
  let(:test_antigen_administered_records) do
    AntigenAdministeredRecord.create_records_from_vaccine_doses(
      test_vaccine_doses
    )
  end

  describe "validations" do
    it 'requires a patient object' do
      expect {
        AntigenEvaluator.new(
          antigen: test_antigen,
          antigen_administered_records: test_antigen_administered_records
        )
      }.to raise_exception(ArgumentError)
    end
    it 'requires an antigen object' do
      expect {
        AntigenEvaluator.new(
          patient: test_patient,
          antigen_administered_records: test_antigen_administered_records
        )
      }.to raise_exception(ArgumentError)
    end
    it 'requires an array of antigen_administered_record object' do
      expect {
        AntigenEvaluator.new(antigen: test_antigen,
                             patient: test_patient)
      }.to raise_exception(ArgumentError)
    end
  end
  describe '#create' do
    it 'automatically evaluates the antigen and sets the status' do
      antigen_evaluator = AntigenEvaluator.new(
        antigen: test_antigen,
        patient: test_patient,
        antigen_administered_records: test_antigen_administered_records
      )
      expect(antigen_evaluator.evaluation_status).to eq('immune')
    end
    it 'automatically will evaluate not_complete for not complete' do
      not_complete_dates = create_valid_dates(test_patient.dob)[0..-2]
      vaccine_doses = create_patient_vaccines(test_patient, not_complete_dates)

      aars = AntigenAdministeredRecord.create_records_from_vaccine_doses(
        vaccine_doses
      )

      antigen_evaluator = AntigenEvaluator.new(
        antigen: test_antigen,
        patient: test_patient,
        antigen_administered_records: aars
      )
      expect(antigen_evaluator.evaluation_status).to eq('not_complete')
    end
    it 'sets the next target dose to nil if the antigen is immune' do
      antigen_evaluator = AntigenEvaluator.new(
        antigen: test_antigen,
        patient: test_patient,
        antigen_administered_records: test_antigen_administered_records
      )
      expect(antigen_evaluator.evaluation_status).to eq('immune')
      expect(antigen_evaluator.next_required_target_dose).to eq(nil)
    end
    it 'sets the next target dose if the antigen is complete' do
      new_test_patient = FactoryGirl.create(:patient,
                                        dob: 2.years.ago.to_date)
      dob = new_test_patient.dob
      date_array = [(dob + 6.weeks), (dob + 12.weeks), (dob + 18.weeks)]
      vaccine_doses = create_patient_vaccines(new_test_patient, date_array, 10)
      new_test_patient.reload

      aars = AntigenAdministeredRecord.create_records_from_vaccine_doses(
        vaccine_doses
      )

      antigen_evaluator = AntigenEvaluator.new(
        antigen: test_antigen,
        patient: new_test_patient,
        antigen_administered_records: aars
      )
      expect(antigen_evaluator.evaluation_status).to eq('complete')

      patient_series = antigen_evaluator.best_patient_series
      expected_target_dose = patient_series.target_doses.last

      expect(antigen_evaluator.next_required_target_dose)
        .to eq(expected_target_dose)
    end
    it 'sets the next target dose if the antigen is not_complete' do
      not_complete_dates = create_valid_dates(test_patient.dob)[0..-2]
      vaccine_doses = create_patient_vaccines(test_patient, not_complete_dates)

      aars = AntigenAdministeredRecord.create_records_from_vaccine_doses(
        vaccine_doses
      )

      antigen_evaluator = AntigenEvaluator.new(
        antigen: test_antigen,
        patient: test_patient,
        antigen_administered_records: aars
      )
      expect(antigen_evaluator.evaluation_status).to eq('not_complete')

      patient_series = antigen_evaluator.best_patient_series
      expected_target_dose = patient_series.target_doses.last

      expect(antigen_evaluator.next_required_target_dose)
        .to eq(expected_target_dose)
    end
  end
end
