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

  def vaccine_info
    Vaccine.find_by(cvx_code: self.cvx_code) if self.cvx_code
  end

  def antigens
    if self.vaccine_info && self.vaccine_info.antigens
      return self.vaccine_info.antigens
    else
      raise 'Vaccine Dose is missing information regarding the vaccine or antigens'
    end
  end
end
