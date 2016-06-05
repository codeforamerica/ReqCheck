class Patient < User
  after_initialize :set_defaults, unless: :persisted?
  has_one :patient_profile
  has_many :immunizations, through: :patient_profile
  delegate :dob, :record_number, :address, :address2, :city, :state, :zip_code, :cell_phone,
    :home_phone, :race, :ethnicity, :immunizations, to: :patient_profile

  accepts_nested_attributes_for :patient_profile

  def self.find_by_record_number(record_number)
    return self.joins(:patient_profile)
      .where(patient_profiles: {record_number: record_number})
      .order("created_at DESC").first
  end

  def set_defaults
    # @immuniation_checker = ImmunizationChecker.new
  end

  # def check_record
  #   @immuniation_checker.check_record(self.immunizations)
  # end
  def check_record
    if self.record_number < 10
      true
    end
    false
  end

  def age
    if self.dob
      convert_to_age(self.dob)
    end
  end

  private

  def convert_to_age(birthday)
    (Time.now.to_s(:number).to_i - birthday.to_time.to_s(:number).to_i)/10e9.to_i
  end


end

      