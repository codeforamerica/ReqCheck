class Patient < User
  has_one :patient_profile
  has_many :immunizations, through: :patient_profile
  delegate :dob, :record_number, :address, :address2, :city, :state, :zip_code, :cell_phone,
    :home_phone, :race, :ethnicity, :immunizations, to: :patient_profile

  accepts_nested_attributes_for :patient_profile
end

      