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

end