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
end
