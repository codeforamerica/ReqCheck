# This will guess the User class
require 'faker'
require_relative 'support/vax_codes'
require_relative 'support/time_help'

FactoryGirl.define do
  extend TimeHelp
  
  factory :vaccine do
    short_description 'Polio'
    full_name 'DTaP-HepB-IPV'
    cvx_code 110
    vaccine_group_cvx 89
    vaccine_group_name 'Polio'
    status 'Active'
  end

  factory :antigen do
    name 'Polio'
  end

  factory :antigen_with_vaccine, parent: :antigen do
    after_create do |antigen|
      antigen.vaccines << FactoryGirl.create(:vaccine)
    end
  end

  
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

  factory :vaccine_dose do
    vaccine_code { TextVax::VAXCODES.keys.sample.to_s }
    imm_date { Date.today }
    send_flag false
    history_flag false
    provider_code "432"
    
    sequence(:manufacturer) do |num|
      vax_array = TextVax::VAXCODES[vaccine_code.to_sym]
      vax_array[(num % vax_array.length)][1]
    end
    sequence(:lot_number) do |num|
      vax_array = TextVax::VAXCODES[vaccine_code.to_sym]
      vax_array[(num % vax_array.length)][2]
    end
    expiration_date { in_pst(2.months.since) }
    dose_number 1
    facility_id 19


    association :patient_profile, factory: :patient_profile
  end

  factory :vaccine_requirement do
    vaccine_code { TextVax::VAXCODES.keys.sample.to_s }
    dosage_number 1
    min_age_years 1
  end

  factory :vaccine_requirement_detail do
    requirer_id 1
    requirement_id 2
    required_years 0
    required_months 1
    required_weeks 0
  end
end