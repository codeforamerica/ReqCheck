require 'rails_helper'
require 'age_evaluation'
require_relative '../support/kcmo_data'


RSpec.describe 'KCMO_HD_Data' do
  before(:all) { FactoryGirl.create(:seed_full_antigen_xml) }
  after(:all) { DatabaseCleaner.clean_with(:truncation) }

  let(:all_patient_data) { KCMODATA::ALL_PATIENTS }

end
