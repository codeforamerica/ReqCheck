# This will guess the User class
require 'faker'
require_relative 'support/vax_codes'
require_relative 'support/time_help'

FactoryGirl.define do
  factory :vaccine_dose_evaluator do
  end
  factory :antigen_evaluator do
  end
  extend TimeHelp

  factory :interval do
    interval_type 'from_previous'
    allowable false

    factory :interval_4_weeks do
      interval_absolute_min '4 weeks - 4 days'
      interval_min '4 weeks'
      interval_earliest_recommended '8 weeks'
      interval_latest_recommended '13 weeks'
    end

    factory :interval_6_months do
      interval_absolute_min '6 months - 4 days'
      interval_min '6 months'
      interval_earliest_recommended '6 months'
      interval_latest_recommended '13 months + 4 weeks'
    end

    factory :interval_4_months_allowable do
      interval_absolute_min '4 months'
      interval_min ''
      interval_earliest_recommended ''
      interval_latest_recommended ''
      allowable true
    end

    factory :interval_8_weeks do
      interval_absolute_min '8 weeks - 4 days'
      interval_min '8 weeks'
      interval_earliest_recommended '8 weeks'
      interval_latest_recommended '18 months + 4 weeks'
    end

    factory :interval_target_dose_16_weeks do
      interval_type 'from_target_dose'
      target_dose_number 1
      interval_absolute_min '16 weeks - 4 days'
      interval_min '16 weeks'
    end

    factory :interval_most_recent_1_year do
      interval_type 'from_most_recent'
      recent_vaccine_type 'PPSV23'
      recent_cvx_code 33
      interval_absolute_min '0 days'
      interval_min '1 year'
      interval_earliest_recommended '1 year'
    end
  end

  factory :conditional_skip_condition do
    condition_id 1
    condition_type 'Age'

    after(:create) do |condition|
      if condition.condition_type == 'Age' && condition.begin_age.nil?
        condition.begin_age = '4 years - 4 days'
      elsif condition.condition_type == 'Interval' && condition.interval.nil?
        condition.interval = '6 months - 4 days'
      end
    end
  end

  factory :conditional_skip_set do
    set_id 1
    set_description('Dose is not required for those 4 years or older when the '\
                    'interval from the last dose is 6 months')
    condition_logic 'AND'

    after(:create) do |conditional_skip_set|
      if conditional_skip_set.conditions.length == 0
        conditional_skip_set.conditions << FactoryGirl.create(
          :conditional_skip_condition
        )
        conditional_skip_set.conditions << FactoryGirl.create(
          :conditional_skip_condition,
          condition_id: 2,
          condition_type: 'Interval',
          interval: '6 months - 4 days'
        )
      end
    end
  end

  factory :conditional_skip do
    set_logic 'n/a'

    after(:create) do |cond_skip|
      if cond_skip.sets.length == 0
        FactoryGirl.create(:conditional_skip_set, conditional_skip: cond_skip)
        cond_skip.reload
      end
    end
  end

  factory :antigen_series_dose_vaccine do
    vaccine_type 'IPV'
    cvx_code 10
    preferable true
    begin_age '6 weeks'
    end_age '5 years'
    volume '0.5'
    trade_name 'test'
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

  factory :antigen_series_dose_with_vaccines, parent: :antigen_series_dose do
    after(:create) do |dose|
      dose.dose_vaccines << FactoryGirl.create(:antigen_series_dose_vaccine)
      dose.dose_vaccines << FactoryGirl.create(
        :antigen_series_dose_vaccine,
        vaccine_type: 'DTaP-HepB-IPV',
        cvx_code: 110,
        begin_age: '6 weeks',
        end_age: '7 years',
        trade_name: '',
        mvx_code: '',
        volume: '0.5'
      )
      dose.dose_vaccines << FactoryGirl.create(
        :antigen_series_dose_vaccine,
        vaccine_type: 'DTaP-IPV',
        cvx_code: 130,
        begin_age: '6 weeks - 4 days',
        end_age: '',
        trade_name: '',
        mvx_code: '',
        volume: '',
        preferable: false
      )
      dose.dose_vaccines << FactoryGirl.create(
        :antigen_series_dose_vaccine,
        vaccine_type: 'IPV',
        cvx_code: 10,
        begin_age: '6 weeks - 4 days',
        end_age: '',
        trade_name: '',
        mvx_code: '',
        volume: '',
        preferable: false
      )
    end
  end

  factory :antigen_series_dose_second_with_vaccines,
          parent: :antigen_series_dose_with_vaccines do
    dose_number 2
    absolute_min_age '10 weeks - 4 days'
    min_age '10 weeks'
    earliest_recommended_age '4 months'
    latest_recommended_age '5 months + 4 weeks'
    max_age '18 years'

    # This will probably fail - need to update as its one to many (or many to many)
    after(:create) do |dose|
      super
      dose.intervals << FactoryGirl.create(:interval_4_weeks,
                                           antigen_series_dose: dose)
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

    after(:create) do |dose|
      dose.intervals << FactoryGirl.create(:interval_4_weeks,
                                           antigen_series_dose: dose)
    end
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
    target_disease 'polio'
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
  end

  factory :patient_with_profile, parent: :patient do
    transient do
      dob false
    end
    after(:create) do |patient, args|
      if args.dob
        create(:patient_profile, patient_id: patient.id.to_s, dob: args.dob)
      else
        create(:patient_profile, patient_id: patient.id.to_s)
      end
    end
  end

  factory :patient_profile do
    dob { 12.years.ago.to_date }
    sequence(:record_number, 11000)

    association :patient, factory: :patient
  end

  factory :vaccine_dose do
    vaccine_code 'POL'
    date_administered { Date.today }
    send_flag false
    history_flag false
    provider_code '432'

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
    expiration_date { 2.months.since.to_date }
    dose_number 1
    facility_id 19
  end

  factory :vaccine_dose_with_patient_profile, parent: :vaccine_dose do
    association :patient_profile, factory: :patient_profile
  end

  factory :vaccine_dose_by_cvx, parent: :vaccine_dose do
    transient do
      vaccine_code 'POL'
      mvx_code 0
      lot_number ''
    end

    before(:create) do |vaccine_dose|
      vaccine_dose.cvx_code = 10 if vaccine_dose.cvx_code.nil?
      vaccine_code =
        TextVax.find_all_vax_codes_by_cvx(vaccine_dose.cvx_code).first
      vax_array = TextVax::VAXCODES[vaccine_code.to_sym]
      vaccine_dose.vaccine_code = vaccine_code
      vaccine_dose.mvx_code = vax_array.first[1]
      vaccine_dose.lot_number = vax_array.first[2]
    end
  end
end
