require 'rails_helper'
require_relative '../support/antigen_xml'

RSpec.describe AntigenImporter, type: :model do
  describe '#create' do
    it 'takes no arguments to instantiate and is stateless' do
      antigen_importer = AntigenImporter.new
      expect(antigen_importer.class.name).to eq('AntigenImporter')
    end
  end
  
  describe '#xml_to_hash' do
    it 'takes an xml string and returns a hash' do
      xml_string = TestAntigen::ANTIGENSTRING
      antigen_importer = AntigenImporter.new
      antigen_hash = antigen_importer.xml_to_hash(xml_string)
      expect(antigen_hash.class.name).to eq('Hash')
    end
    it 'has the first level xml tag as the top level key' do
      xml_string = '<testXML><levelOne><level2></level2></levelOne></testXML>'
      antigen_importer = AntigenImporter.new
      antigen_hash = antigen_importer.xml_to_hash(xml_string)
      expect(antigen_hash.has_key?('testXML')).to be_truthy
    end
    it 'uses key strings as lookups and not symbols' do
      xml_string = '<testXML><levelOne><level2></level2></levelOne></testXML>'
      antigen_importer = AntigenImporter.new
      antigen_hash = antigen_importer.xml_to_hash(xml_string)
      expect(antigen_hash['testXML']).to be_truthy
      expect(antigen_hash[:testXML]).to eq(nil)
    end
    it 'turns single tags into a key/value pair' do
      xml_string = '<testXML><levelOne><level2><something /></level2></levelOne></testXML>'
      antigen_importer = AntigenImporter.new
      antigen_hash = antigen_importer.xml_to_hash(xml_string)
      expect(antigen_hash['testXML']['levelOne']['level2'].class.name).to eq('Hash')
    end
    it 'turns multipe tags into an Array' do
      xml_string = '<testXML><levelOne><level2><something /></level2><level2><something /> \
                    </level2></levelOne></testXML>'
      antigen_importer = AntigenImporter.new
      antigen_hash = antigen_importer.xml_to_hash(xml_string)
      expect(antigen_hash['testXML']['levelOne']['level2'].class.name).to eq('Array')
    end
  end

  describe 'pulling data from the xml hash' do
    let(:antigen_importer) { AntigenImporter.new }
    let(:xml_string) { TestAntigen::ANTIGENSTRING } 
    let(:xml_hash) { antigen_importer.xml_to_hash(xml_string) } 

    describe '#get_cvx_for_antigen' do
      it 'takes an antigen xml and returns an array of the cvx codes' do
        expect(antigen_importer.get_cvx_for_antigen(xml_hash)).
          to eq([10, 110, 120, 130, 132, 146, 2, 89])
      end
    end
    
    describe '#find_or_create_all_vaccines' do
      it 'will pull all vaccines if already in the database' do
        cvx1, cvx2 = 10, 12
        vaccine  = Vaccine.create(cvx_code: 10)
        vaccine2 = Vaccine.create(cvx_code: 12)
        expect(antigen_importer.find_or_create_all_vaccines([10, 12])).
          to eq([vaccine, vaccine2])
      end
      it 'will create all vaccines if none are there' do
        cvx1, cvx2 = 10, 12
        expect(antigen_importer.find_or_create_all_vaccines([10, 12]).
          map { |vaccine| vaccine.cvx_code }).
          to eq([cvx1, cvx2])
      end
      it 'will create neccesary vaccines that are not in the database' do
        cvx1, cvx2 = 10, 12
        vaccine    = Vaccine.create(cvx_code: cvx1)
        expect(Vaccine.all.length).to eq(1)
        expect(antigen_importer.find_or_create_all_vaccines([10, 12]).
          map { |vaccine| vaccine.cvx_code }).
          to eq([cvx1, cvx2])
        expect(Vaccine.all.length).to eq(2)
      end
    end

    describe '#add_vaccines_to_antigen' do
      it 'takes an array of vaccines and antigen name' do
        vaccines = [FactoryGirl.create(:vaccine)]
        antigen  = FactoryGirl.create(:antigen)
        expect(antigen.vaccines).to eq([])
        antigen_importer.add_vaccines_to_antigen(antigen.name, vaccines)
        antigen.reload
        expect(antigen.vaccines).to eq(vaccines)
      end
      it 'will error if the antigen does not exist' do
        vaccines = [FactoryGirl.create(:vaccine)]
        expect {antigen_importer.add_vaccines_to_antigen(antigen.name, vaccines)}.
          to raise_exception
      end
    end

    xdescribe '#to_cvx_hash' do
      it 'pulls every cvx from the xml and creates a hash with cvx as the key' do
        cvx_hash   = antigen_importer.to_cvx_hash(xml_hash)
        expect(cvx_hash.keys.length).to be(100)
      end
    end
  end
end
