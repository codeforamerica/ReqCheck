require 'rails_helper'
require 'target_dose_evaluation'

RSpec.describe TargetDoseEvaluation do
  before(:all) { FactoryGirl.create(:seed_antigen_xml_polio) }
  after(:all) { DatabaseCleaner.clean_with(:truncation) }

  let(:test_object) do
    class TestClass
      include AgeEvaluation
    end
    TestClass.new
  end


end
