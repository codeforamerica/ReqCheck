require 'rails_helper'
require 'age_evaluation'
require_relative '../support/kcmo_data'


RSpec.describe 'KCMO_HD_Data' do
  include AntigenImporterSpecHelper
  include KCMODATA

  before(:all) do
    seed_full_antigen_xml
    KCMODATA.create_db_patients
  end
  after(:all) do
    KCMODATA.delete_db_patients
    DatabaseCleaner.clean_with(:truncation)
  end

  it 'has all db patients' do
    expect(KCMODATA.all_db_patients.length).to eq(21)
  end

  it 'testing' do
    KCMODATA.all_db_patients.each do |db_patient|
      puts '#####################'
      puts db_patient.first_name
      puts db_patient.last_name
      puts db_patient.evaluation_status
      puts db_patient.evaluation_details
      puts '#####################'
    end
  end

  KCMODATA.all_db_patients.each do |db_patient|
    record_number = db_patient.record_number
    expected_evaluation = get_expected_record_status(record_number)
    not_complete_vaccine_groups =
      get_expected_not_complete_vaccine_groups(record_number)

    xdescribe "patient with record_number #{patient.record_number}" do
      it "\#evaluation_status evaluates to #{expected_evaluation}" do
        expect(db_patient.evaluation_status).to eq(expected_evaluation)
      end
      it "\#evaluation_details has vaccine groups" \
         "#{not_complete_vaccine_groups} evaluate to not_complete" do
        not_complete_vaccine_groups.each do |vaccine_group|
          expect(db_patient.evaluation_details[vaccine_group.to_sym])
            .to eq('not_complete')
        end
      end
    end
  end

end
