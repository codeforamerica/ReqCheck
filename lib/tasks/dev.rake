namespace :db do
  desc 'basically reset, but without the seed data'
  namespace :clear do
    task patients: :environment do
      Rails.logger.level = 1 # hides all the SQL for development
      Patient.destroy_all
      Immunization.destroy_all
      PatientProfile.destroy_all
      Rails.logger.info "All Patients, Immunizations, PatientProfiles deleted from #{Rails.env} DB"
    end
  end
end