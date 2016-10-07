module PatientValidator
  def pull_patient_profile_attrs(all_attrs)
    patient_profile_attrs = [
      :patient_number, :dob, :address, :address2, :city, :state,
      :zip_code, :cell_phone, :home_phone, :race, :ethnicity,
      :gender, :hd_mpfile_updated_at
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
        "Missing arguments #{missing_args} for Patient"
      )
    end
  end

  def check_extraneous_args(args)
    temp_args = args.clone
    [
      :patient_number, :dob, :address, :address2, :city, :state,
      :zip_code, :cell_phone, :home_phone, :race, :ethnicity,
      :gender, :first_name, :last_name, :email, :hd_mpfile_updated_at
    ].each do |allowable_arg|
      temp_args.delete(allowable_arg)
    end
    unless temp_args == {}
      extraneous_arg_names = temp_args.keys
      raise ArgumentError.new(
        "Extraneous arguments #{extraneous_arg_names} for Patient"
      )
    end
  end
end
