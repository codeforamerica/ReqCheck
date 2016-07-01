class Patient < User
  after_initialize :set_defaults, unless: :persisted?
  has_one :patient_profile
  has_many :vaccine_doses, through: :patient_profile
  delegate :dob, :record_number, :address, :address2, :city, :state, :zip_code, :cell_phone,
    :home_phone, :race, :ethnicity, :vaccine_doses, to: :patient_profile

  accepts_nested_attributes_for :patient_profile
  include TimeCalc

  def self.find_by_record_number(record_number)
    return self.joins(:patient_profile)
      .where(patient_profiles: {record_number: record_number})
      .order("created_at DESC").first
  end

  def set_defaults

  end

  def check_record
    if self.record_number < 10
      true
    end
    false
  end

  def age
    if self.dob
      TimeCalc.date_diff_in_years(self.dob)
    end
  end

  def age_in_days
    if self.dob
      TimeCalc.date_diff_in_days(self.dob)
    end
  end

  def get_vaccines(vaccine_array)
    vax = self.vaccine_doses.select { |vaccine| vaccine_array.include? vaccine.vaccine_code }
      .sort_by { |vaccine_dose| vaccine_dose.administered_date }
  end

end

      