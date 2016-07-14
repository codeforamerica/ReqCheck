# This will guess the User class
require 'faker'
require_relative 'support/vax_codes'
require_relative 'support/time_help'

FactoryGirl.define do
  extend TimeHelp

  factory :conditional_skip_set_condition do
    
  end

  factory :conditional_skip_set do
    
  end

  factory :conditional_skip do
    
  end

  factory :antigen_series_dose_vaccine do
    vaccine_type 'IPV'
    cvx_code 10
    preferable true
    begin_age '6 weeks'
    volume '0.5'
    forecast_vaccine_type false
  end

  factory :antigen_series_dose do
    dose_number 1
    absolute_min_age '6 weeks - 4 days'
    min_age '6 weeks'
    earliest_recommended_age '2 months'
    latest_recommended_age '3 months + 4 weeks'
    max_age '18 years'
    interval_type 'None'
    
    after(:create) do |dose|
      dose.dose_vaccines << FactoryGirl.create(:antigen_series_dose_vaccine)
    end
  end

  factory :antigen_series_dose_second do
    dose_number 2
    absolute_min_age '10 weeks - 4 days'
    min_age '10 weeks'
    earliest_recommended_age '4 months'
    latest_recommended_age '5 months + 4 weeks'
    max_age '18 years'
    interval_type 'Previous'
    interval_absolute_min '4 weeks - 4 days'
    interval_min '4 weeks'
    interval_earliest_recommended '8 weeks'
    interval_latest_recommended '13 weeks'

    association :prefered_vaccine, factory: :antigen_series_dose_vaccine
  end
  
  factory :antigen_series do
    name 'Polio - All IPV - 4 Dose'
    target_disease 'Polio'
    vaccine_group 'Polio'
    default_series true
    product_path true
    preference_number 1
    min_start_age 'n/a'
    max_start_age 'n/a'
  end
  
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
    after(:create) do |antigen|
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
    administered_date { Date.today }
    send_flag false
    history_flag false
    provider_code "432"
    
    sequence(:mvx_code) do |num|
      vax_array = TextVax::VAXCODES[vaccine_code.to_sym]
      vax_array[(num % vax_array.length)][1]
    end
    sequence(:lot_number) do |num|
      vax_array = TextVax::VAXCODES[vaccine_code.to_sym]
      vax_array[(num % vax_array.length)][2]
    end
    sequence(:cvx_code) do |num|
      vax_array = TextVax::VAXCODES[vaccine_code.to_sym]
      vax_array[(num % vax_array.length)][3]
    end
    expiration_date { in_pst(2.months.since) }
    dose_number 1
    facility_id 19


    association :patient_profile, factory: :patient_profile
  end

  factory :vaccine_dose_with_vaccine, parent: :vaccine_dose do
    after(:create) do |vaccine_dose|
      antigen = FactoryGirl.create(:antigen)
      vaccine = FactoryGirl.create(:vaccine, cvx_code: vaccine_dose.cvx_code)
      antigen.vaccines << vaccine
    end
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