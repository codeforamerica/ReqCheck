require 'rails_helper'
require 'future_dose_evaluation'

RSpec.describe FutureDoseEvaluation do
  include AntigenImporterSpecHelper
  include PatientSpecHelper

  before(:all) { seed_antigen_xml_polio }
  after(:all) { DatabaseCleaner.clean_with(:truncation) }

  let(:test_object) do
    class TestClass
      include FutureDoseEvaluation
    end
    TestClass.new
  end

  let(:polio_catch_up_patient) do
    patient_dob = 2.years.ago.to_date
    test_patient = FactoryGirl.create(:patient_with_profile,
                                      dob: patient_dob)
    vaccine_dates = [(patient_dob + 6.weeks), (patient_dob + 10.weeks)]
    create_patient_vaccines(test_patient, vaccine_dates, cvx_code = 10)
    test_patient
  end

  let(:polio_up_to_date_patient) do
    patient_dob = 2.years.ago.to_date
    test_patient = FactoryGirl.create(:patient_with_profile,
                                      dob: patient_dob)
    vaccine_dates = [
      (patient_dob + 6.weeks),
      (patient_dob + 10.weeks),
      (patient_dob + 14.weeks)
    ]
    create_patient_vaccines(test_patient, vaccine_dates, cvx_code = 10)
    test_patient
  end

  def create_future_target_dose(patient)
    intervals = [FactoryGirl.create(:interval_6_months)]
    as_dose = FactoryGirl.create(
      :antigen_series_dose_with_vaccines,
      absolute_min_age: '1 year - 4 days',
      min_age: '1 year',
      earliest_recommended_age: '1 year + 2 months',
      latest_recommended_age: '5 years',
      max_age: '18 years',
      intervals: intervals
    )
    TargetDose.new(patient: patient, antigen_series_dose: as_dose)
  end

  describe '#create_future_dose_dates' do
    it 'returns an array of dates' do
      vaccine_doses = polio_up_to_date_patient.vaccine_doses
      satisfied_target_doses = create_fake_valid_target_doses(vaccine_doses)
      future_target_dose = create_future_target_dose(polio_up_to_date_patient)
      future_dose_dates = test_object.create_future_dose_dates(
        polio_up_to_date_patient,
        future_target_dose,
        vaccine_doses: polio_up_to_date_patient.vaccine_doses,
        satisfied_target_doses: satisfied_target_doses)
      expect(false).to eq(true)
    end
  end
  describe '#find_maximium_min_date' do
    it 'returns the latest min_date' do
      today = Date.today
      future_dose_dates = [
        {
          absolute_min_age_date: (today - 1.year - 4.days),
          min_age_date: (today - 1.year),
          earliest_recommended_age_date: (today - 10.years),
          latest_recommended_age_date: (today + 3.years),
          max_age_date: (today + 16.years)
        },
        {
          interval_absolute_min_date: (today - 1.year - 3.months + 2.days),
          interval_min_date: (today - 1.year - 3.months + 4.days),
          interval_earliest_recommended_date: (
            today - 1.year - 3.months + 4.days
          ),
          interval_latest_recommended_date: (today - 7.months + 4.days)
        }
      ]
      expected_maximum_min_date = (today - 1.year)
      maximum_min_date = test_object.find_maximium_min_date(future_dose_dates)
      expect(maximum_min_date).to eq(expected_maximum_min_date)
    end
  end
end
