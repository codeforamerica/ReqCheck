require 'rails_helper'
require 'age_evaluation'
require_relative '../support/kcmo_data'


RSpec.describe 'KCMO_HD_Data' do
  include AntigenImporterSpecHelper
  include KCMODATA

  before(:all) do
    seed_full_antigen_xml
    KCMODATA.create_db_patients

    # Ensure the assessment date is 9/28/2016 so that many of the patients
    #  are not up to date but cannot get a vaccine due to a catch up schedule
    new_time = Time.local(2016, 9, 28, 10, 0, 0)
    Timecop.freeze(new_time)
  end

  after(:all) do
    KCMODATA.delete_db_patients
    DatabaseCleaner.clean_with(:truncation)
    Timecop.return
  end

  it 'has all db patients' do
    expect(KCMODATA.all_db_patients.length).to eq(21)
  end

  # it 'testing' do
  #   KCMODATA.all_db_patients.each do |db_patient|
  #     puts '#####################'
  #     puts db_patient.dob
  #     puts db_patient.first_name
  #     puts db_patient.last_name
  #     puts db_patient.evaluation_status
  #     puts db_patient.evaluation_details
  #     puts db_patient.future_dose_dates
  #     puts '#####################'
  #   end
  # end

  # KCMODATA.all_db_patients.each do |db_patient|
  #   record_number = db_patient.record_number
  #   expected_evaluation = get_expected_record_status(record_number)
  #   not_complete_vaccine_groups =
  #     get_expected_not_complete_vaccine_groups(record_number)

  #   xdescribe "patient with record_number #{patient.record_number}" do
  #     it "\#evaluation_status evaluates to #{expected_evaluation}" do
  #       expect(db_patient.evaluation_status).to eq(expected_evaluation)
  #     end
  #     it "\#evaluation_details has vaccine groups" \
  #        "#{not_complete_vaccine_groups} evaluate to not_complete" do
  #       not_complete_vaccine_groups.each do |vaccine_group|
  #         expect(db_patient.evaluation_details[vaccine_group.to_sym])
  #           .to eq('not_complete')
  #       end
  #     end
  #   end
  # end

  KCMODATA.expected_results.each do |key, value|
    record_number = value[0]
    expected_evaluation = value[1]
    expected_future_dates  = value[2]

    describe "patient with record_number #{record_number}" do
      it "\#evaluation_status evaluates to #{expected_evaluation}" do
        db_patient = KCMODATA.all_db_patient_profiles.find_by(
          record_number: record_number
        ).patient
        expect(db_patient.evaluation_status).to eq(expected_evaluation)
      end
      it "\#future_dose_dates equals the expected_future_dose_dates" do
        db_patient = KCMODATA.all_db_patient_profiles.find_by(
          record_number: record_number
        ).patient
        expect(db_patient.future_dose_dates).to eq(expected_future_dates)
      end
      it "\#future_dose_dates for hep b" do
        db_patient = KCMODATA.all_db_patient_profiles.find_by(
          record_number: record_number
        ).patient
        target_dose = db_patient.future_dose('hepb')
        # if target_dose.nil?
        #   byebug
        # end
        latest_vax  = db_patient.vaccine_doses.where(
          cvx_code: [8, 42, 43, 44, 45, 51, 102, 104, 110, 132]
        ).last
        new_expected_future_dates = []
        if target_dose.nil?
          expect(nil).to eq(db_patient.future_dose_dates[:hepb])
        else
          target_dose.intervals.each do |i|
            date_string = i.interval_min
            new_expected_future_dates << target_dose.create_patient_age_date(
              date_string,
              latest_vax.date_administered
            )
            expect(new_expected_future_dates).to include(db_patient.future_dose_dates[:hepb])
          end
        end
      end
    end
  end
  # KCMODATA.all_db_patients.each do |db_patient|
  #   xdescribe "patient with record_number #{patient.record_number}" do
  #     it "\#evaluation_status evaluates to #{expected_evaluation}" do
  #       expect(db_patient.evaluation_status).to eq(expected_evaluation)
  #     end
  #     it "\#evaluation_details has vaccine groups" \
  #        "#{not_complete_vaccine_groups} evaluate to not_complete" do
  #       not_complete_vaccine_groups.each do |vaccine_group|
  #         expect(db_patient.evaluation_details[vaccine_group.to_sym])
  #           .to eq('not_complete')
  #       end
  #     end
  #   end
  # end

end
