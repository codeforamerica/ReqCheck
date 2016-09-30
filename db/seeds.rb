# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
require_relative '../spec/support/vax_codes'
require_relative '../spec/support/kcmo_data'

patients_list = [
  ['Jared', 'Leto', '02/08/1990', 'M'],
  ['James', 'Halstead', '03/12/1989', 'M'],
  ['Coco', 'Crisp', '04/22/1990', 'M'],
  ['OilCan', 'Boyd', '05/18/1985', 'M'],
  ['Nomar', 'Garciaparra', '06/15/1992', 'M'],
  ['Manny', 'Ramirez', '12/07/1978', 'M'],
  ['Leslie', 'Ortiz', '11/01/1981', 'F'],
  ['Jane', 'Vaughn', '10/28/1988', 'F'],
  ['Samantha', 'Nixon', '09/26/1994', 'F'],
  ['Laura', 'Wakefield', '06/24/1998', 'F'],
  ['Nuria', 'Pedroia', '08/13/2000', 'F']
]

patients_list.each_with_index do |value, index|
  patient = Patient.create(
    first_name: value[0], last_name: value[1],
    email: "#{value[1]}#{index.to_s}@example.com",
    patient_profile_attributes: {
      dob: Date.strptime(value[2], '%m/%d/%Y'), record_number: (index + 1),
      gender: value[3]
    }
  )
  vaccine_types = ["MCV6", "DTaP", "MMR9", "HepB"]
  vaccine_types.each do |vax_code|
    vax_code_key = vax_code.to_sym
    description   = TextVax::VAXCODES[vax_code_key][0][0]
    mvx_code      = TextVax::VAXCODES[vax_code_key][0][1]
    lot_number    = TextVax::VAXCODES[vax_code_key][0][2]
    cvx_code      = TextVax::VAXCODES[vax_code_key][0][3]
    trade_name    = TextVax.trade_name_lookup(cvx_code, mvx_code)
    VaccineDose.create(
      patient_profile: patient.patient_profile,
      vaccine_code: vax_code,
      description: description,
      date_administered: 2.years.ago.to_date,
      mvx_code: mvx_code,
      lot_number: lot_number,
      cvx_code: cvx_code,
      trade_name: trade_name
    )
    VaccineDose.create(
      patient_profile: patient.patient_profile,
      vaccine_code: vax_code,
      description: description,
      date_administered: 1.years.ago.to_date,
      mvx_code: mvx_code,
      lot_number: lot_number,
      cvx_code: cvx_code,
      trade_name: trade_name
    )
    VaccineDose.create(
      patient_profile: patient.patient_profile,
      vaccine_code: vax_code,
      description: description,
      date_administered: Date.today,
      mvx_code: mvx_code,
      lot_number: lot_number,
      cvx_code: cvx_code,
      trade_name: trade_name
    )
  end
end

antigen_importer = AntigenImporter.new
antigen_importer.import_antigen_xml_files('spec/support/xml')

KCMODATA.create_db_patients
