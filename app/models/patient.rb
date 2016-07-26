class Patient < User
  after_initialize :set_defaults, unless: :persisted?
  has_one :patient_profile
  has_many :vaccine_doses, through: :patient_profile
  delegate :dob, :record_number, :address, :address2, :city, :state, :zip_code, :cell_phone,
    :home_phone, :race, :ethnicity, :gender, :vaccine_doses, to: :patient_profile

  accepts_nested_attributes_for :patient_profile
  include TimeCalc

  def self.find_by_record_number(record_number)
    return self.joins(:patient_profile)
      .where(patient_profiles: {record_number: record_number})
      .order("created_at DESC").first
  end

  def self.create_full_profile(first_name:, last_name:, dob:, record_number:, email: '', **options)
    allowable_keys = [:record_number, :dob, :address, :address2, :city, :state,
                      :zip_code, :cell_phone, :home_phone, :race, :ethnicity, :gender]
    options.keys.each do |key_symbol|
      if !allowable_keys.include? key_symbol
        raise ArgumentError.new("unknown attribute #{key_symbol.to_s} for PatientProfile")
      end
    end
    options[:dob]           = dob
    options[:record_number] = record_number
    options = options.symbolize_keys
    self.create(first_name: first_name, last_name: last_name, email: email,
                patient_profile_attributes: options)
  end

  def set_defaults

  end

  def check_record
    # if self.record_number < 10
    #   true
    # end
    # false
    'valid'
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

  def get_vaccine_doses(vaccine_code_array)
    vax = self.vaccine_doses.select { |vaccine_dose| vaccine_code_array.include? vaccine_dose.vaccine_code }
      .sort_by { |vaccine_dose| vaccine_dose.administered_date }
  end

end

      