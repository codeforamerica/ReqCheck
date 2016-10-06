class PatientProfile < ActiveRecord::Base
  belongs_to :patient
  has_many :vaccine_doses

  validates :patient_number, numericality: { greater_than: 0, strict: true }
  before_save :standardise_gender

  def standardise_gender
    gender = self.gender.downcase unless gender.nil?
    gender = gender[0] if gender == 'female' || gender == 'male'
    self.gender = gender
  end
end
