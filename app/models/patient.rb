class Patient < User
  after_initialize :set_defaults, unless: :persisted?
  has_one :patient_profile
  has_many :vaccine_doses, through: :patient_profile
  delegate :dob, :patient_number, :address, :address2, :city, :state, :zip_code, :cell_phone,
    :home_phone, :race, :ethnicity, :gender, :vaccine_doses, to: :patient_profile

  accepts_nested_attributes_for :patient_profile

  include TimeCalc

  def self.find_by_patient_number(patient_number)
    return self.joins(:patient_profile)
      .where(patient_profiles: {patient_number: patient_number})
      .order("created_at DESC").first
  end

  def self.create_full_profile(first_name:, last_name:, dob:, patient_number:, email: '', **options)
    allowable_keys = [:patient_number, :dob, :address, :address2, :city, :state,
                      :zip_code, :cell_phone, :home_phone, :race, :ethnicity, :gender]
    options.keys.each do |key_symbol|
      if !allowable_keys.include? key_symbol
        raise ArgumentError.new("unknown attribute #{key_symbol.to_s} for PatientProfile")
      end
    end
    options[:dob]           = dob
    options[:patient_number] = patient_number
    options = options.symbolize_keys
    self.create(first_name: first_name, last_name: last_name, email: email,
                patient_profile_attributes: options)
  end

  def set_defaults

  end

  def check_record
    # if self.patient_number < 10
    #   true
    # end
    # false
    'valid'
  end

  def age
    if self.dob
      date_diff_in_years(self.dob)
    end
  end

  def age_in_days
    if self.dob
      date_diff_in_days(self.dob)
    end
  end

  def get_vaccine_doses(vaccine_code_array)
    self.vaccine_doses.select do |vaccine_dose|
      vaccine_code_array.include? vaccine_dose.vaccine_code
    end.sort_by { |vaccine_dose| vaccine_dose.date_administered }
  end

  def antigen_administered_records
    @antigen_administered_records ||= AntigenAdministeredRecord
                                        .create_records_from_vaccine_doses(
                                          self.vaccine_doses
                                        )
  end

  def evaluate_record
    @record_evaluator = nil
    record_evaluator
  end

  def record_evaluator
    @record_evaluator ||= RecordEvaluator.new(patient: self)
  end

  def evaluation_status
    record_evaluator.record_status
  end

  def evaluation_details
    record_evaluator.vaccine_group_evaluations
  end

  def future_dose_dates
    record_evaluator.vaccine_groups_next_target_doses
  end

  def future_dose(vaccine_group_name)
    vaccine_group_evaluator =
      record_evaluator.get_vaccine_group_evaluator(vaccine_group_name)
    return nil if vaccine_group_evaluator.nil?
    vaccine_group_evaluator.next_target_dose
  end

end


