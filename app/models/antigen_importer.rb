class AntigenImporter
  include ActiveModel::Model

  def import_xml_file(xml_file)

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

  def add_vaccines_to_antigen(antigen_string, vaccine_array)
    antigen = Antigen.find_by(name: antigen_string)
    antigen.vaccines << vaccine_array
  end
end
