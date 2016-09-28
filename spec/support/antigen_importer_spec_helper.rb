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
  def seed_antigen_xml_hib
    antigen_importer = AntigenImporter.new
    antigen_importer.import_single_file(
      'spec/support/xml/AntigenSupportingData- Hib.xml'
    )
  end
  def seed_xml_to_antigen_mapping
    antigen_importer = AntigenImporter.new
    antigen_importer.import_single_file(
      'spec/support/xml/ScheduleSupportingData.xml'
    )
  end
  def seed_full_antigen_xml
    antigen_importer = AntigenImporter.new
    antigen_importer.import_antigen_xml_files('spec/support/xml')
  end
end
