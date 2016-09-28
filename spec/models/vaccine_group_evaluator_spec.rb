require 'rails_helper'

RSpec.describe VaccineGroupEvaluator, type: :model do
  include AntigenImporterSpecHelper
  include PatientSpecHelper

  before(:all) { seed_antigen_xml_polio }
  after(:all) { DatabaseCleaner.clean_with(:truncation) }

end
