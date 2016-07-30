require 'rails_helper'

RSpec.describe Antigen, type: :model do
  describe '#create' do
    it 'requires a name' do
      expect{ Antigen.create }.to raise_exception
      expect(Antigen.create(target_disease: 'Test').class.name).to eq('Antigen')
    end
    it 'has a json field named xml_hash' do
      xml_hash = {"hello": "world"}.stringify_keys
      antigen = Antigen.create(target_disease: 'Test', xml_hash: xml_hash)
      expect(Antigen.first.xml_hash).to eq(xml_hash)
    end
  end

  describe 'relationships' do
    context 'new import method' do
      it 'has many series' do
        antigen = FactoryGirl.create(:antigen)
        antigen_series = FactoryGirl.create(:antigen_series)
        antigen.series << antigen_series
        expect(antigen.series).to eq([antigen_series])
      end
      it 'orders the series by preference_number' do
        antigen = FactoryGirl.create(:antigen)
        antigen_series1 = FactoryGirl.create(:antigen_series, preference_number: 3, antigen: antigen)
        antigen_series3 = FactoryGirl.create(:antigen_series, antigen: antigen)
        antigen_series2 = FactoryGirl.create(:antigen_series, preference_number: 2, antigen: antigen)
        expect(antigen.series.map(&:preference_number)).to eq([1, 2, 3])
      end
      it 'has many doses' do
        antigen               = FactoryGirl.create(:antigen)
        expect(antigen.doses.length).to eq(0)
        antigen_series        = FactoryGirl.create(:antigen_series, antigen: antigen)
        antigen_series2       = FactoryGirl.create(:antigen_series, antigen: antigen)
        antigen_series_dose1 = FactoryGirl.create(:antigen_series_dose,
                                                   antigen_series: antigen_series)
        antigen_series_dose2 = FactoryGirl.create(:antigen_series_dose,
                                                   antigen_series: antigen_series)
        antigen_series_dose3 = FactoryGirl.create(:antigen_series_dose,
                                                   antigen_series: antigen_series2)
        antigen_series_dose4 = FactoryGirl.create(:antigen_series_dose,
                                                   antigen_series: antigen_series2)
        antigen.reload
        expect(antigen.doses.length).to eq(4)
      end
      it 'has many dose_vaccines' do
        antigen               = FactoryGirl.create(:antigen)
        expect(antigen.dose_vaccines.length).to eq(0)
        antigen_series        = FactoryGirl.create(:antigen_series, antigen: antigen)
        antigen_series2       = FactoryGirl.create(:antigen_series, antigen: antigen)
        antigen_series_dose1 = FactoryGirl.create(:antigen_series_dose,
                                                   antigen_series: antigen_series)
        antigen_series_dose2 = FactoryGirl.create(:antigen_series_dose,
                                                   antigen_series: antigen_series)
        antigen_series_dose3 = FactoryGirl.create(:antigen_series_dose,
                                                   antigen_series: antigen_series2)
        antigen_series_dose4 = FactoryGirl.create(:antigen_series_dose,
                                                   antigen_series: antigen_series2)
        antigen_series_doses = [antigen_series_dose1, antigen_series_dose2,
                                antigen_series_dose3, antigen_series_dose4]
        antigen_series_doses.each do |as_dose|
          as_dose.dose_vaccines << FactoryGirl.create(:antigen_series_dose_vaccine)
          as_dose.dose_vaccines << FactoryGirl.create(:antigen_series_dose_vaccine)
        end
        antigen.reload
        expect(antigen.dose_vaccines.length).to eq(8)
      end
    end
    context 'old import method' do
      it 'has multiple vaccines' do
        antigen = Antigen.create(target_disease: 'Polio')
        vaccine_info = FactoryGirl.create(:vaccine_info)
        antigen.vaccine_infos << vaccine_info
        expect(antigen.vaccine_infos).to eq([vaccine_info])
      end
    end
  end

  describe '#all_antigen_cvx_codes' do
    let(:antigen) do
      antigen_importer = AntigenImporter.new
      antigen_xml_hash = antigen_importer.xml_to_hash(TestAntigen::ANTIGENSTRING)
      antigen_importer.parse_antigen_data_and_create_subobjects(antigen_xml_hash)
    end

    it 'pulls all cvx codes from the antigen\'s series\'s dose\'s vaccines' do
      a_vaccines  = antigen.series.map {|series| series.doses }
                      .flatten!.map {|dose| dose.dose_vaccines }.flatten!
      
      expect(antigen.dose_vaccines.uniq.sort).to eq(a_vaccines.uniq.sort)
      expect(antigen.all_antigen_cvx_codes).to eq(a_vaccines.map(&:cvx_code).uniq.sort)
    end
  end

  describe '#find_antigens_by_cvx' do
    before(:each) do
      antigen_importer = AntigenImporter.new
      antigen_importer.import_antigen_xml_files('spec/support/xml')
    end

    it 'finds all antigens per the cvx code' do
      cvx_code = 110
      antigens = Antigen.find_antigens_by_cvx(cvx_code)
      expect(antigens.length).to eq(5)
      ["tetanus", "polio", "pertussis", "hepb", "diphtheria"].each do |target_disease|
        antigen_index = antigens.index{ |antigen_obj| antigen_obj.target_disease == target_disease }
        antigens.delete_at(antigen_index)
      end
      expect(antigens).to eq([])
    end
  end
end
