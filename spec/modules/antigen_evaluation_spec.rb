require 'rails_helper'
require 'antigen_evaluation'

RSpec.describe AntigenEvaluation do
  before(:all) { FactoryGirl.create(:seed_antigen_xml_polio) }
  after(:all) { DatabaseCleaner.clean_with(:truncation) }

  let(:test_object) do
    class TestClass
      include AntigenEvaluation
    end
    TestClass.new
  end

  let(:test_patient) do
    test_patient = FactoryGirl.create(:patient_with_profile)
  end

  def create_patient_vaccines(test_patient, vaccine_dates, cvx_code=10)
    vaccines = vaccine_dates.map.with_index do |vaccine_date, index|
      FactoryGirl.create(
        :vaccine_dose_by_cvx,
        patient_profile: test_patient.patient_profile,
        dose_number: (index + 1),
        date_administered: vaccine_date,
        cvx_code: cvx_code
      )
    end
    test_patient.reload
    vaccines
  end

  def create_valid_dates(start_date)
    [
      start_date + 6.weeks,
      start_date + 12.weeks,
      start_date + 18.weeks,
      start_date + 4.years
    ]
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
      new_test_patient = FactoryGirl.create(:patient_with_profile,
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
      new_test_patient = FactoryGirl.create(:patient_with_profile,
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
      new_test_patient = FactoryGirl.create(:patient_with_profile,
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
  describe '#get_all_patient_series_evaluations ' do
    it 'takes patient_serieses and antigen_administered_records and returns' \
       'a status hash' do
      patient_dob      = 2.years.ago
      new_test_patient = FactoryGirl.create(:patient_with_profile,
                                            dob: patient_dob)
      valid_dates   = create_valid_dates(new_test_patient.dob)
      vaccine_doses = create_patient_vaccines(new_test_patient, valid_dates[0..-2])

      aars = AntigenAdministeredRecord.create_records_from_vaccine_doses(
        vaccine_doses
      )
      test_patient_serieses = PatientSeries.create_antigen_patient_serieses(
        patient: new_test_patient,
        antigen: polio_antigen
      )
      evaluation_hash = test_object.get_all_patient_series_evaluations(
        test_patient_serieses,
        aars
      )

      expected_result = 'complete'
      expect(evaluation_hash).to eq(expected_result)
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
      evaluation_hash = test_object.get_all_patient_series_evaluations(
        test_patient_serieses,
        aars
      )

      expected_result = 'immune'
      expect(evaluation_hash).to eq(expected_result)
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
      evaluation_hash = test_object.get_all_patient_series_evaluations(
        test_patient_serieses,
        aars
      )

      expected_result = 'immune'
      expect(evaluation_hash).to eq(expected_result)
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
      evaluation_hash = test_object.get_all_patient_series_evaluations(
        test_patient_serieses,
        aars
      )

      expected_result = 'immune'
      expect(evaluation_hash).to eq(expected_result)
    end
    it 'takes returns not_complete if none are complete' do
      patient_dob      = 2.years.ago
      new_test_patient = FactoryGirl.create(:patient_with_profile,
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
      evaluation_hash = test_object.get_all_patient_series_evaluations(
        test_patient_serieses,
        aars
      )

      expected_result = 'not_complete'
      expect(evaluation_hash).to eq(expected_result)
    end
  end
  describe '#evaluate_antigen ' do
    it 'takes an antigen, patient and antigen_administered_records and returns' \
       'a status hash' do
      valid_dates   = create_valid_dates(test_patient.dob)
      vaccine_doses = create_patient_vaccines(test_patient, valid_dates)

      aars = AntigenAdministeredRecord.create_records_from_vaccine_doses(
        vaccine_doses
      )
      evaluation_hash = test_object.evaluate_antigen(
        polio_antigen,
        test_patient,
        aars
      )

      expected_result = 'immune'
      expect(evaluation_hash).to eq(expected_result)
    end
    it 'returns incomplete if incomplete' do
      valid_dates   = create_valid_dates(test_patient.dob)
      vaccine_doses = create_patient_vaccines(test_patient, valid_dates[0..-2])

      aars = AntigenAdministeredRecord.create_records_from_vaccine_doses(
        vaccine_doses
      )
      evaluation_hash = test_object.evaluate_antigen(
        polio_antigen,
        test_patient,
        aars
      )

      expected_result = 'not_complete'
      expect(evaluation_hash).to eq(expected_result)
    end
  end
end
