class AntigenAdministeredRecord
  include ActiveModel::Model

  attr_accessor :antigen, :vaccine

  def initialize(antigen:, vaccine_dose:)
    @antigen      = antigen
    @vaccine_dose = vaccine_dose
  end

  def self.create_records_from_vaccine_doses(vaccine_doses)
    antigen_records = []
    vaccine_doses.each do |vaccine_dose|
      vaccine_dose.antigens.each do |antigen|
        antigen_records << self.new(antigen: antigen, vaccine_dose: vaccine_dose)
      end
    end
    antigen_records
  end
# antigen administered record
# - antigen 
# - date administered
# - vaccine type (cvx)
# - manufacturer (mvx)
# - trade name
# - amount
# - lot expiration date
# - dose condition

end