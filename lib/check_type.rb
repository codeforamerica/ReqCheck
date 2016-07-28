module CheckType
  def enforce_type(object, expected_type)
    if !object.instance_of? expected_type
      raise TypeError.new("wrong argument type #{object} (expected #{expected_type})")
    end
  end
  module_function :enforce_type
end