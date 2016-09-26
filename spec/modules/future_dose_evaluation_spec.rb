require 'rails_helper'
require 'future_dose_evaluation'

RSpec.describe FutureDoseEvaluation do
  include AntigenImporterSpecHelper

  before(:all) { seed_antigen_xml_polio }
  after(:all) { DatabaseCleaner.clean_with(:truncation) }

  let(:test_object) do
    class TestClass
      include FutureDoseEvaluation
    end
    TestClass.new
  end
end
