# This will guess the User class
FactoryGirl.define do
  factory :patient do
    first_name "Test"
    last_name  "Tester"
    
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