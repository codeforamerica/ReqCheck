# This will guess the User class
require 'faker'
require_relative 'support/vax_codes'
require_relative 'support/time_help'

FactoryGirl.define do
  extend TimeHelp
  factory :interval do
    interval_type 'Previous'
    interval_absolute_min '4 weeks - 4 days'
    interval_min '4 weeks'
    interval_earliest_recommended '8 weeks'
    interval_latest_recommended '13 weeks'
    allowable false
  end

  factory :seed_antigen_xml, class: Hash do
    skip_create

    before(:create) do
      antigen_importer = AntigenImporter.new
      antigen_importer.import_antigen_xml_files('spec/support/xml')
    end
  end


  factory :conditional_skip_set_condition do
    condition_id 1
    condition_type 'Age'

    after(:create) do |condition|
      if condition.condition_type == 'Age' && condition.start_age.nil?
        condition.start_age = '4 years - 4 days'
      elsif condition.condition_type == 'Interval' && condition.interval.nil?
        condition.interval = '6 months - 4 days'
      end
    end
  end

  factory :conditional_skip_set do
    set_id 1
    set_description 'Dose is not required for those 4 years or older when the interval from the '\
    'last dose is 6 months'
    condition_logic 'AND'

    after(:create) do |cond_skip_set|
      cond_skip_set.conditions << FactoryGirl.create(:conditional_skip_set_condition)
      cond_skip_set.conditions << FactoryGirl.create(:conditional_skip_set_condition,
        condition_id: 2,
        condition_type: 'Interval',
        interval: '6 months - 4 days'
      )
    end
  end

  factory :conditional_skip do
    set_logic 'n/a'

    after(:create) do |cond_skip|
      if !cond_skip.sets
        FactoryGirl.create(:conditional_skip_set, conditional_skip: cond_skip)
      end
    end
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
  end

  factory :antigen_series_dose_with_vaccine, parent: :antigen_series_dose do
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
    
    # This will probably fail - need to update as its one to many (or many to many)
    association :prefered_vaccine, factory: :antigen_series_dose_vaccine
    association :iinterval, factory: :interval
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
  
  factory :vaccine_info do
    short_description 'Polio'
    full_name 'DTaP-HepB-IPV'
    cvx_code 110
    vaccine_group_cvx 89
    vaccine_group_name 'Polio'
    status 'Active'
  end

  factory :antigen do
    target_disease 'Polio'
  end

  factory :antigen_with_vaccine_info, parent: :antigen do
    after(:create) do |antigen|
      antigen.vaccines << FactoryGirl.create(:vaccine_info)
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

  # factory :vaccine_dose_with_vaccine_info, parent: :vaccine_dose do
  #   after(:create) do |vaccine_dose|
  #     antigen = FactoryGirl.create(:antigen)
  #     vaccine = FactoryGirl.create(:vaccine_info, cvx_code: vaccine_dose.cvx_code)
  #     antigen.vaccines << vaccine
  #   end
  # end
end