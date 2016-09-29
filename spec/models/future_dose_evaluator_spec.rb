require 'rails_helper'

RSpec.describe FutureDoseEvaluator, type: :model do
  include AntigenImporterSpecHelper
  include PatientSpecHelper

  before(:all) do
    seed_full_antigen_xml
  end
  after(:all) do
    DatabaseCleaner.clean_with(:truncation)
  end

  let(:test_patient) { valid_5_year_test_patient }
  let(:future_dose_evaluator) do
    FutureDoseEvaluator.new(patient: test_patient)
  end


end
