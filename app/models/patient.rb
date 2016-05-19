class Patient < User
  has_one :patient_profile
  delegate :dob, to: :patient_profile
end
