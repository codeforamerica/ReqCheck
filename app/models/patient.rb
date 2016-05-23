class Patient < User
  has_one :patient_profile
  delegate :dob, :record_number, :address, :address2, :city, :state, :zip_code, :cell_phone,
    :home_phone, :race, :ethnicity, to: :patient_profile
end

      