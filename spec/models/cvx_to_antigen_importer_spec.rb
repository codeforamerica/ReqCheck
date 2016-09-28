require 'rails_helper'
require_relative '../support/antigen_xml'

RSpec.describe CvxToAntigenImporter, type: :model do
  describe '#create' do
    it 'takes no arguments to instantiate' do
      cvx_to_antigen_importer = CvxToAntigenImporter.new
      expect(cvx_to_antigen_importer.class.name).to eq('CvxToAntigenImporter')
    end
  end
end
