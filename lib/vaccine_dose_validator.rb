module VaccineDoseValidator
  def check_required_vaccine_dose_args(args)
    missing_args = []
    [
      :patient_profile, :cvx_code, :date_administered
    ].each do |vaccine_dose_args|
      missing_args << vaccine_dose_args.to_s if args[vaccine_dose_args].nil?
    end
    unless missing_args == []
      raise ArgumentError.new(
        "Missing arguments #{missing_args} for VaccineDose"
      )
    end
  end

  def check_extraneous_args_vaccine_dose(args)
    temp_args = args.clone
    [
      :vaccine_code, :patient_profile_id, :date_administered, :hd_description,
      :history_flag, :provider_code, :dosage, :mvx_code, :lot_number,
      :expiration_date, :hd_encounter_id, :vfc_code, :cvx_code,
      :vfc_description, :given_by, :injection_site, :hd_imfile_updated_at,
      :patient_profile
    ].each do |allowable_arg|
      temp_args.delete(allowable_arg)
    end
    unless temp_args == {}
      extraneous_arg_names = temp_args.keys
      raise ArgumentError.new(
        "Extraneous arguments #{extraneous_arg_names} for VaccineDose"
      )
    end
  end
end
