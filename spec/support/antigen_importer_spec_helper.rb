module AntigenImporterSpecHelper
  def seed_antigen_xml_polio
    antigen_importer = AntigenImporter.new
    antigen_importer.import_single_file(
      'spec/support/xml/AntigenSupportingData- Polio.xml'
    )
  end
  def seed_antigen_xml_hpv
    antigen_importer = AntigenImporter.new
    antigen_importer.import_single_file(
      'spec/support/xml/AntigenSupportingData- HPV.xml'
    )
  end
  def seed_full_antigen_xml
    antigen_importer = AntigenImporter.new
    antigen_importer.import_antigen_xml_files('spec/support/xml')
  end
end
