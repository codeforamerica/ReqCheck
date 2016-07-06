class AntigenImporter
  include ActiveModel::Model
  # attr_accessor :email, :message
  def xml_to_hash(xml_string)
    Hash.from_xml(xml_string)
  end

  def get_cvx_for_antigen(xml_hash)
    xml_hash.find_all_values_for('cvx', numeric=true)
  end
end
