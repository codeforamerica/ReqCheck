class Immunization < ActiveRecord::Base
  belongs_to :patient_profile
  has_one :patient, through: :patient_profile
end
