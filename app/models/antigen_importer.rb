class AntigenImporter
  include ActiveModel::Model

  def import_antigen_xml_files(xml_directory)
    file_names = Dir[xml_directory + "/*.xml" ]
    file_names.each do |file_name|
      file_hash = parse_and_hash(file_name)
      if file_name.include? 'Schedule'

      elsif file_name.include? 'Antigen'
        cvx_codes = get_cvx_for_antigen(file_hash)
        vaccines = find_or_create_all_vaccines(cvx_codes)
        antigen_name = file_hash.find_all_values_for('targetDisease').first
        add_vaccines_to_antigen(antigen_name, vaccines)
      end
    end
  end

  def parse_and_hash(xml_file_path)
    file = File.open(xml_file_path, "r")
    data = file.read
    file.close
    xml_to_hash(data)
  end

  def xml_to_hash(xml_string)
    Hash.from_xml(xml_string)
  end

  def get_cvx_for_antigen(xml_hash)
    xml_hash.find_all_values_for('cvx', numeric=true)
  end

  def find_or_create_all_vaccines(cvx_array)
    cvx_array.map do |cvx_code|
      Vaccine.find_or_create_by(cvx_code: cvx_code)
    end
  end

  def add_vaccines_to_antigen(antigen_string, vaccine_array, xml_hash)
    antigen = Antigen.find_or_create_by(name: antigen_string)
    antigen.xml_hash = xml_hash
    antigen.save
    antigen.vaccines << vaccine_array
  end
end
