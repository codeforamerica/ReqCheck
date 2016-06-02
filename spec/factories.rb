# This will guess the User class
require 'faker'

FactoryGirl.define do
  factory :patient do
    sequence(:first_name, 1) { |n| "Test#{n}" }
    sequence(:last_name, 1) { |n| "Tester#{n}" }
    sequence(:email, 1) { |n| "test#{n}@example.com" }   
    
    after(:create) do |patient| 
      create(:patient_profile, patient_id: "#{patient.id}")
    end
  end

  factory :patient_profile do
    dob { 21.years.ago }
    sequence(:record_number, 1000)

    association :patient, factory: :patient
  end

  factory :immunization do
    vaccine_code { vax_codes.keys.sample.to_s }
    # patient_profile_id
    # imm_date { Date.today }
    # send_flag false
    # history_flag false
    # provider_code "432"
    
    manufacturer { vax_codes[self.vaccine_code.to_sym][0] }
    # lot_number
    expiration_date { 2.months.since }
    dose_number 1
    facility_id 19


    association :patient, factory: :patient
  end

end