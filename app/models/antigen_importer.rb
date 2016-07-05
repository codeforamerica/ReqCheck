class AntigenImporter
  include ActiveModel::Model
  # attr_accessor :email, :message
  def xml_to_hash(xml_string)
    Hash.from_xml(xml_string)
  end
end
