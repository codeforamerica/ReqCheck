require 'rails_helper'
require 'antigen_evaluation'

RSpec.describe AntigenEvaluation do
  include PatientSpecHelper
  include AntigenImporterSpecHelper

  before(:all) { seed_antigen_xml_polio }
  after(:all) { DatabaseCleaner.clean_with(:truncation) }

  let(:test_object) do
    class TestClass
      include AntigenEvaluation
    end
    TestClass.new
  end

  let(:test_patient) do
    test_patient = FactoryGirl.create(:patient)
  end

  let(:polio_antigen) do
    Antigen.find_by(target_disease: 'polio')
  end

  let(:test_antigen_series) do
    polio_antigen.series.first
  end

  describe '#get_patient_series_evaluation ' do
    it 'takes a patient_series and antigen_administered_records and returns' \
       'a status hash' do
      valid_dates   = create_valid_dates(test_patient.dob)
      vaccine_doses = create_patient_vaccines(test_patient, valid_dates)
      aars = AntigenAdministeredRecord.create_records_from_vaccine_doses(
        vaccine_doses
      )
      test_patient_series = PatientSeries.new(
        patient: test_patient,
        antigen_series: test_antigen_series
      )
      evaluation_hash = test_object.get_patient_series_evaluation(
        test_patient_series,
        aars
      )

      expected_result = 'immune'
      expect(evaluation_hash).to eq(expected_result)
    end
    it 'returns complete for patient that is complete but not immune' do
      patient_dob      = 2.years.ago
      new_test_patient = FactoryGirl.create(:patient,
                                            dob: patient_dob)
      valid_dates   = create_valid_dates(new_test_patient.dob)
      vaccine_doses = create_patient_vaccines(new_test_patient, valid_dates[0..-2])

      aars = AntigenAdministeredRecord.create_records_from_vaccine_doses(
        vaccine_doses
      )
      test_patient_series = PatientSeries.new(
        patient: new_test_patient,
        antigen_series: test_antigen_series
      )

      evaluation_hash = test_object.get_patient_series_evaluation(
        test_patient_series,
        aars
      )

      expected_result = 'complete'
      expect(evaluation_hash).to eq(expected_result)
    end
    it 'returns not_complete for patient that is not up to date' do
      patient_dob      = 2.years.ago
      new_test_patient = FactoryGirl.create(:patient,
                                            dob: patient_dob)
      valid_dates   = create_valid_dates(new_test_patient.dob)
      vaccine_doses = create_patient_vaccines(new_test_patient, valid_dates[0..-3])

      aars = AntigenAdministeredRecord.create_records_from_vaccine_doses(
        vaccine_doses
      )
      test_patient_series = PatientSeries.new(
        patient: new_test_patient,
        antigen_series: test_antigen_series
      )

      evaluation_hash = test_object.get_patient_series_evaluation(
        test_patient_series,
        aars
      )

      expected_result = 'not_complete'
      expect(evaluation_hash).to eq(expected_result)
    end
    it 'returns not_complete for patient that has an invalid dose (interval)' do
      patient_dob      = 2.years.ago
      new_test_patient = FactoryGirl.create(:patient,
                                            dob: patient_dob)
      valid_dates   = create_valid_dates(new_test_patient.dob)
      new_dates     = valid_dates[0..-3]
      new_dates     = new_dates << (new_dates.last + 2.weeks)
      vaccine_doses = create_patient_vaccines(new_test_patient, new_dates)

      aars = AntigenAdministeredRecord.create_records_from_vaccine_doses(
        vaccine_doses
      )
      test_patient_series = PatientSeries.new(
        patient: new_test_patient,
        antigen_series: test_antigen_series
      )

      evaluation_hash = test_object.get_patient_series_evaluation(
        test_patient_series,
        aars
      )

      expected_result = 'not_complete'
      expect(evaluation_hash).to eq(expected_result)
    end
  end
  describe '#pull_best_patient_series ' do
    it 'takes patient_serieses and antigen_administered_records and returns' \
       'the most complete series' do
      patient_dob      = 2.years.ago
      new_test_patient = FactoryGirl.create(:patient,
                                            dob: patient_dob)
      valid_dates   = create_valid_dates(new_test_patient.dob)
      vaccine_doses = create_patient_vaccines(new_test_patient,
                                              valid_dates[0..-2])

      aars = AntigenAdministeredRecord.create_records_from_vaccine_doses(
        vaccine_doses
      )
      test_patient_serieses = PatientSeries.create_antigen_patient_serieses(
        patient: new_test_patient,
        antigen: polio_antigen
      )
      best_series = test_object.pull_best_patient_series(
        test_patient_serieses,
        aars
      )

      expected_status            = 'complete'
      expect(best_series.series_status).to eq(expected_status)

      expected_preference_number = 1
      expect(best_series.preference_number).to eq(expected_preference_number)
    end
    it 'returns immune if immune' do
      valid_dates   = create_valid_dates(test_patient.dob)
      vaccine_doses = create_patient_vaccines(test_patient, valid_dates)

      aars = AntigenAdministeredRecord.create_records_from_vaccine_doses(
        vaccine_doses
      )
      test_patient_serieses = PatientSeries.create_antigen_patient_serieses(
        patient: test_patient,
        antigen: polio_antigen
      )
      best_series = test_object.pull_best_patient_series(
        test_patient_serieses,
        aars
      )

      expected_status            = 'immune'
      expect(best_series.series_status).to eq(expected_status)

      expected_preference_number = 1
      expect(best_series.preference_number).to eq(expected_preference_number)
    end
    it 'returns immune if immune even if last series' do
      valid_dates   = create_valid_dates(test_patient.dob)
      vaccine_doses = create_patient_vaccines(
        test_patient,
        valid_dates,
        02
      )

      aars = AntigenAdministeredRecord.create_records_from_vaccine_doses(
        vaccine_doses
      )
      test_patient_serieses = PatientSeries.create_antigen_patient_serieses(
        patient: test_patient,
        antigen: polio_antigen
      )
      best_series = test_object.pull_best_patient_series(
        test_patient_serieses,
        aars
      )

      expected_status            = 'immune'
      expect(best_series.series_status).to eq(expected_status)
      expect(true).to eq(false)
      # Need to figure out how to set this up for it to be the last patient series
      expected_preference_number = 3
      expect(best_series.preference_number).to eq(expected_preference_number)
    end
    it 'returns immune if immune is the second series (but not first)' do
      valid_dates   = create_valid_dates(test_patient.dob)
      vaccine_doses = create_patient_vaccines(
        test_patient,
        valid_dates,
        89
      )

      aars = AntigenAdministeredRecord.create_records_from_vaccine_doses(
        vaccine_doses
      )
      test_patient_serieses = PatientSeries.create_antigen_patient_serieses(
        patient: test_patient,
        antigen: polio_antigen
      )
      best_series = test_object.pull_best_patient_series(
        test_patient_serieses,
        aars
      )

      expected_status            = 'immune'
      expect(best_series.series_status).to eq(expected_status)

      expected_preference_number = 2
      expect(best_series.preference_number).to eq(expected_preference_number)
    end
    it 'returns not_complete if none are complete' do
      patient_dob      = 2.years.ago
      new_test_patient = FactoryGirl.create(:patient,
                                            dob: patient_dob)
      valid_dates   = create_valid_dates(new_test_patient.dob)
      new_dates     = valid_dates[0..-3]
      new_dates     = new_dates << (new_dates.last + 2.weeks)
      vaccine_doses = create_patient_vaccines(new_test_patient, new_dates)

      aars = AntigenAdministeredRecord.create_records_from_vaccine_doses(
        vaccine_doses
      )
      test_patient_serieses = PatientSeries.create_antigen_patient_serieses(
        patient: new_test_patient,
        antigen: polio_antigen
      )
      best_series = test_object.pull_best_patient_series(
        test_patient_serieses,
        aars
      )

      expected_status            = 'not_complete'
      expect(best_series.series_status).to eq(expected_status)

      expected_preference_number = 1
      expect(best_series.preference_number).to eq(expected_preference_number)
    end
  end
  describe '#evaluate_antigen_for_patient_series ' do
    it 'takes an antigen, patient and antigen_administered_records and returns' \
       'the most complete patient series' do
      valid_dates   = create_valid_dates(test_patient.dob)
      vaccine_doses = create_patient_vaccines(test_patient, valid_dates)

      aars = AntigenAdministeredRecord.create_records_from_vaccine_doses(
        vaccine_doses
      )
      best_patient_series = test_object.evaluate_antigen_for_patient_series(
        polio_antigen,
        test_patient,
        aars
      )

      expected_result = 'immune'
      expect(best_patient_series.series_status).to eq(expected_result)
    end
    it 'returns incomplete if incomplete' do
      valid_dates   = create_valid_dates(test_patient.dob)
      vaccine_doses = create_patient_vaccines(test_patient, valid_dates[0..-2])

      aars = AntigenAdministeredRecord.create_records_from_vaccine_doses(
        vaccine_doses
      )
      best_patient_series = test_object.evaluate_antigen_for_patient_series(
        polio_antigen,
        test_patient,
        aars
      )

      expected_result = 'not_complete'
      expect(best_patient_series.series_status).to eq(expected_result)
    end
  end
end
