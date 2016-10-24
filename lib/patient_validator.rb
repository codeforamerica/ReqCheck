module PatientValidator
  def check_required_patient_args(args)
    missing_args = []
    [
      :patient_number, :dob, :first_name, :last_name
    ].each do |patient_arg|
      missing_args << patient_arg.to_s if args[patient_arg].nil?
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
      :gender, :first_name, :last_name, :email, :hd_mpfile_updated_at, :notes,
      :family_number
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
