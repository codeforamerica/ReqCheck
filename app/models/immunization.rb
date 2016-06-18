class Immunization < ActiveRecord::Base
  belongs_to :patient_profile
  has_one :patient, through: :patient_profile

  def patient_age_at_immunization
    unless self.patient.nil?
      TimeCalc.detailed_date_diff(self.patient.dob, self.imm_date)
    else
      'N/A'
    end
  end

  def time_since_immunization
    TimeCalc.detailed_date_diff(self.imm_date)
  end
end
