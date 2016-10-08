class VaccineDose < ActiveRecord::Base
  belongs_to :patient_profile
  has_one :patient, through: :patient_profile

  include TimeCalc
  extend VaccineDoseValidator

  before_save :upcase_vaccine_code

  def upcase_vaccine_code
    self.vaccine_code = self.vaccine_code.upcase unless vaccine_code.nil?
  end


  before_save :upcase_vaccine_code

  def upcase_vaccine_code
    self.vaccine_code = self.vaccine_code.upcase unless vaccine_code.nil?
  end


  def patient_age_at_vaccine_dose
    if !self.patient.nil?
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

  def validate_condition
    true
  end

  def self.create_by_patient_profile(patient_profile, **options)
    options.delete('patient_number') if options.has_key?(:patient_number)
    options[:patient_profile] = patient_profile

    self.check_required_vaccine_dose_args(options)
    self.check_extraneous_args_vaccine_dose(options)
    self.create(patient_profile: patient_profile, **options)
  end

end
