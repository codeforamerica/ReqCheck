# This will guess the User class
require 'faker'
require_relative 'support/vax_codes'
require_relative 'support/time_help'

FactoryGirl.define do
  extend TimeHelp
  factory :patient do
    sequence(:first_name, 1) { |n| "Test#{n}" }
    sequence(:last_name, 1) { |n| "Tester#{n}" }
    sequence(:email, 1) { |n| "test#{n}@example.com" }   
    
    after(:create) do |patient| 
      create(:patient_profile, patient_id: "#{patient.id}")
    end
  end

  factory :patient_profile do
    dob { in_pst(21.years.ago) }
    sequence(:record_number, 1000)

    association :patient, factory: :patient
  end

  factory :immunization do
    vaccine_code { TextVax::VAXCODES.keys.sample.to_s }
    imm_date { Date.today }
    send_flag false
    history_flag false
    provider_code "432"
    
    sequence(:manufacturer, 0) { |n| TextVax::VAXCODES[vaccine_code.to_sym][n][0] }
    sequence(:lot_number, 0) { |n| TextVax::VAXCODES[vaccine_code.to_sym][n][2] }
    expiration_date { in_pst(2.months.since) }
    dose_number 1
    facility_id 19


    association :patient_profile, factory: :patient_profile
  end

end