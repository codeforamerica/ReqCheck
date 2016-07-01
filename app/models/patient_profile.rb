class PatientProfile < ActiveRecord::Base
  belongs_to :patient
  has_many :vaccine_doses
end