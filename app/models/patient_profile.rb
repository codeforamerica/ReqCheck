class PatientProfile < ActiveRecord::Base
  belongs_to :patient
  has_many :vaccine_doses

  before_save :standardise_gender

  def standardise_gender
    gender = self.gender.downcase if !self.gender.nil?
    if gender == 'female' || gender == 'male'
      gender = gender[0]
    end
    self.gender = gender
  end
end