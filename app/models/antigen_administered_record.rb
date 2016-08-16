class AntigenAdministeredRecord
  include ActiveModel::Model

  attr_accessor :antigen, :vaccine_dose

  def initialize(antigen:, vaccine_dose:)
    @antigen      = antigen
    @vaccine_dose = vaccine_dose
  end

  [
    'date_administered', 'cvx_code', 'mvx_code',
    'dosage', 'expiration_date', 'patient', 'vaccine_info'
  ].each do |action|
    define_method(action) do
      if @vaccine_dose.nil?
        raise(ArgumentError('AntigenAdministeredRecord requires a vaccine_dose'))
      end
      @vaccine_dose.send(action)
    end
  end

  def target_disease
    @antigen.target_disease
  end

  def full_name
    self.vaccine_info.nil? ? nil : self.vaccine_info.full_name
  end
  
  def self.create_records_from_vaccine_doses(vaccine_doses)
    antigen_records = []
    vaccine_doses.each do |vaccine_dose|
      antigens = Antigen.find_antigens_by_cvx(vaccine_dose.cvx_code)
      raise Exceptions::MissingCVX if antigens.empty?
      antigens.each do |antigen_object|
        antigen_records << self.new(antigen: antigen_object, vaccine_dose: vaccine_dose)
      end
    end
    antigen_records
  end

  def validate_lot_expiration_date
    @vaccine_dose.validate_lot_expiration_date
  end

  def evaluate_dose_condition
    # page 33
  end

  def cdc_attributes
    {
      antigen: self.target_disease,
      date_administered: self.date_administered,
      cvx_code: self.cvx_code,
      mvx_code: self.mvx_code,
      trade_name: self.full_name,
      amount: self.dosage,
      lot_expiration_date: self.expiration_date
    }
  end
end