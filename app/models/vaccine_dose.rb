class VaccineDose < ActiveRecord::Base
  belongs_to :patient_profile
  has_one :patient, through: :patient_profile

  def patient_age_at_vaccine_dose
    unless self.patient.nil?
      TimeCalc.detailed_date_diff(self.patient.dob, self.administered_date)
    else
      'N/A'
    end
  end

  def time_since_vaccine_dose
    TimeCalc.detailed_date_diff(self.administered_date)
  end
end
