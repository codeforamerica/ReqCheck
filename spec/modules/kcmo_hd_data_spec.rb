require 'rails_helper'
require 'age_evaluation'
require_relative '../support/kcmo_data'


RSpec.describe 'KCMO_HD_Data' do
  include AntigenImporterSpecHelper

  before(:all) do
    seed_full_antigen_xml
    KCMODATA.create_db_patients
  end
  after(:all) do
    KCMODATA.delete_db_patients
    DatabaseCleaner.clean_with(:truncation)
  end

  let(:all_patients) { KCMODATA.all_db_patients }

  it 'has all db patients' do
    expect(all_patients.length).to eq(21)
  end

end
