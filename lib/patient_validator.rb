module PatientValidator
  def pull_patient_profile_attrs(all_attrs)
    patient_profile_attrs = [
      :patient_number, :dob, :address, :address2, :city, :state,
      :zip_code, :cell_phone, :home_phone, :race, :ethnicity, :gender
    ]
    return_attrs = {}
    patient_profile_attrs.each do |attribute|
      unless all_attrs[attribute].nil?
        return_attrs[attribute] = all_attrs[attribute]
      end
    end
    return_attrs.symbolize_keys
  end

  def pull_patient_attrs(all_attrs)
    patient_attrs = [:first_name, :last_name, :email]
    return_attrs = {}
    patient_attrs.each do |attribute|
      unless all_attrs[attribute].nil?
        return_attrs[attribute] = all_attrs[attribute]
      end
    end
    return_attrs.symbolize_keys
  end

  def separate_patient_and_profile_attrs(all_attrs)
    return_attrs = {}
    return_attrs[:patient_profile_attrs] =
      pull_patient_profile_attrs(all_attrs)
    return_attrs[:patient_attrs] =
      pull_patient_attrs(all_attrs)
    return_attrs
  end

  def check_required_patient_args(args)
    missing_args = []
    [
      :patient_number, :dob, :first_name, :last_name
    ].each do |profile_arg|
      missing_args << profile_arg.to_s if args[profile_arg].nil?
    end
    unless missing_args == []
      raise ArgumentError.new(
        "Missing arguments #{missing_args} for new Patient"
      )
    end
  end
end
