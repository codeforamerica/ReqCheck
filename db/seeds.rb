# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)



patients_list = [
  [ "Kevin", "Berry", "02/08/1990"],
  [ "James", "Halstead", "03/12/1989"],
  [ "Coco", "Crisp", "04/22/1990"],
  [ "OilCan", "Boyd", "05/18/1985"],
  [ "Nomar", "Garciaparra", "06/15/1992"],
  [ "Manny", "Ramirez", "12/07/1978"],
  [ "David", "Ortiz", "11/01/1981"],
  [ "Mo", "Vaughn", "10/28/1988"],
  [ "Trot", "Nixon", "09/26/1994"],
  [ "Tim", "Wakefield", "06/24/1998"],
  [ "Dustin", "Pedroia", "08/13/2000"],
]

patients_list.each_with_index do |value, index|
  Patient.create( first_name: value[0], last_name: value[1],
    email: "#{value[1]}#{index.to_s}@example.com",
    patient_profile_attributes: {
      dob: Date.strptime(value[2], '%m/%d/%Y'), record_number: (index + 1)
    }
  )
end