class VaccineDose < ActiveRecord::Base
  belongs_to :patient_profile
  has_one :patient, through: :patient_profile

  include TimeCalc

  def patient_age_at_vaccine_dose
    unless self.patient.nil?
      detailed_date_diff(self.patient.dob, self.date_administered)
    else
      'N/A'
    end
  end

  def time_since_vaccine_dose
    detailed_date_diff(self.date_administered)
  end

  def vaccine_info
    VaccineInfo.find_by(cvx_code: self.cvx_code) if self.cvx_code
  end

  def antigens
    if self.vaccine_info && self.vaccine_info.antigens
      return self.vaccine_info.antigens
    else
      raise 'Vaccine Dose is missing information regarding the vaccine or antigens'
    end
  end

  def validate_lot_expiration_date
    self.date_administered <= self.expiration_date
  end
end
