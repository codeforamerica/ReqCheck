class Patient < ActiveRecord::Base
  extend PatientValidator
  include TimeCalc

  validates :first_name, :last_name, :dob, presence: true, strict: true
  validates :patient_number, numericality: { greater_than: 0, strict: true }
  # has_many :vaccine_doses, -> { order(:date_administered) }
  has_many :vaccine_doses, -> { order(:date_administered) },
           foreign_key: :patient_number,
           primary_key: :patient_number

  before_save :standardise_gender
  after_initialize :set_defaults, unless: :persisted?

  def standardise_gender
    gender = self.gender.downcase unless gender.nil?
    gender = gender[0] if gender == 'female' || gender == 'male'
    self.gender = gender
  end

  def self.find_by_patient_number(patient_number)
    patient_number = patient_number.to_i if patient_number.is_a? String
    return self.where(patient_number: patient_number)
      .order("created_at DESC").first
  end

  def self.create_full_profile(first_name:,
                               last_name:,
                               dob:,
                               patient_number:,
                               **options)
    allowable_keys = [
      :patient_number, :dob, :address, :address2, :city, :state,
      :zip_code, :cell_phone, :home_phone, :race, :ethnicity,
      :gender, :hd_mpfile_updated_at, :email
    ]
    options.keys.each do |key_symbol|
      if !allowable_keys.include? key_symbol
        raise ArgumentError.new(
          "unknown attribute #{key_symbol.to_s} for Patient"
        )
      end
    end

    options[:dob]           = dob
    options[:patient_number] = patient_number
    options[:first_name] = first_name
    options[:last_name] = last_name
    options = options.symbolize_keys

    self.create(**options)
  end

  def self.find_or_create_by_patient_number(patient_number,
                                            **options)
    patient = self.find_by_patient_number(patient_number)
    if patient.nil?
      patient = Patient.create_full_profile(patient_number: patient_number,
                                            **options)
    end
    patient
  end

  def self.update_or_create_by_patient_number(**options)
    self.check_required_patient_args(options)
    self.check_extraneous_args(options)
    patient = self.find_by_patient_number(options[:patient_number])
    if patient.nil?
      patient = Patient.create_full_profile(**options)
    else
      patient.update(**options)
    end
    patient
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
    vaccine_code_array.map! { |vaccine_code| vaccine_code.upcase }
    self.vaccine_doses.select do |vaccine_dose|
      vaccine_code_array.include? vaccine_dose.vaccine_code
    end.sort_by { |vaccine_dose| vaccine_dose.date_administered }
  end

  def group_to_array(vaccine_group_name)
    {
      'Diptheria, Tetanus, Pertussis': ["DTHI", "DTI", "TDP9", "TDP1", "TDP2", "TDP9", "Td", "DTaP", "TD4", "TD2", "TD9", "DHI", "TD5", "TDP4", "DTP"],
      'HIB': ["DHI", "PRPO", "PRPT", "HIB", "HIB2"],
      'Hepatitis A': ["HAV1", "HAV3", "HAV4", "HAV5", "HAV6", "HAV9", "TWN1", "TWN3", "TWNz"],
      'Hepatitis B': ["DTHI", "HAV1", "HAV3", "HAV4", "HAV5", "HAV6", "HAV9", "HBIG", "HBV1", "HBV3", "HBV6", "HBV9", "HepB"],
      'Human Papillomavirus': ["HPV", "HPV3", "HPV5", "HPV6", "HPV9"],
      'Measles, Mumps, Rubella': ["MMR", "MMR1", "MMR3", "MMR9", "MMRV"],
      'Meningococcal': ["MCV3", "MCV4", "MCV5", "MCV6", "MCV7", "MCV9"],
      'Pneumococcal': ["PPV2", "PCV4", "PCV2", "PCV9", "PCV", "PPV1", "PPV9", "PPV2"],
      'Polio': ["DTHI", "DTI", "DHI", "POL", "IPV"],
      'Rotavirus': ["ROT1", "ROT2", "ROTA"],
      'Varicella': ["VAR1", "VAR2", "VAR4", "VAR9"],
      'Influenza': ["FL10", "FL11", "FL14", "FLU", "FLU6", "FLU7", "FLU8", "FLU9", "FLUZ", "FLZ", "H1N4"],
      'Travel & Other': ["YFV", "TYP", "TWNz", "TWN3", "TWN1", "RAB1", "PPD9", "PPD1"]
    }[vaccine_group_name.to_sym]
  end

  def get_vaccine_doses_by_group_name(vaccine_group_name)
    vaccine_code_array = group_to_array(vaccine_group_name)
    vaccine_code_array.map! { |vaccine_code| vaccine_code.upcase }
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


