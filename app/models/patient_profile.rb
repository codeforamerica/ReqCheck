class PatientProfile < ActiveRecord::Base
  belongs_to :patient
  has_many :immunizations
end