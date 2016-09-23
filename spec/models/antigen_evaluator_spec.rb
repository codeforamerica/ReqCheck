require 'rails_helper'

RSpec.describe AntigenEvaluator, type: :model do
  before(:all) { FactoryGirl.create(:seed_antigen_xml_polio) }
  after(:all) { DatabaseCleaner.clean_with(:truncation) }

  let(:test_antigen) { Antigen.find_by(target_disease: 'polio') }
  let(:test_patient) { FactoryGirl.create(:patient_with_profile) }


  def create_patient_vaccines(test_patient, vaccine_dates, cvx_code=10)
    vaccines = vaccine_dates.map.with_index do |vaccine_date, index|
      FactoryGirl.create(
        :vaccine_dose_by_cvx,
        patient_profile: test_patient.patient_profile,
        dose_number: (index + 1),
        date_administered: vaccine_date,
        cvx_code: cvx_code
      )
    end
    test_patient.reload
    vaccines
  end

  def create_valid_dates(start_date)
    [
      start_date + 6.weeks,
      start_date + 12.weeks,
      start_date + 18.weeks,
      start_date + 4.years
    ]
  end

  let(:test_vaccine_doses) do
    valid_dates = create_valid_dates(test_patient.dob)
    create_patient_vaccines(test_patient, valid_dates)
  end
  let(:test_antigen_administered_records) do
    AntigenAdministeredRecord.create_records_from_vaccine_doses(
      test_vaccine_doses
    )
  end

  describe "validations" do
    it 'requires a patient object' do
      expect {
        AntigenEvaluator.new(
          antigen: test_antigen,
          antigen_administered_records: test_antigen_administered_records
        )
      }.to raise_exception(ArgumentError)
    end
    it 'requires an antigen object' do
      expect {
        AntigenEvaluator.new(
          patient: test_patient,
          antigen_administered_records: test_antigen_administered_records
        )
      }.to raise_exception(ArgumentError)
    end
    it 'requires an array of antigen_administered_record object' do
      expect {
        AntigenEvaluator.new(antigen: test_antigen,
                             patient: test_patient)
      }.to raise_exception(ArgumentError)
    end
  end
  describe '#create' do
    it 'automatically evaluates the antigen and sets the status' do
      antigen_evaluator = AntigenEvaluator.new(
        antigen: test_antigen,
        patient: test_patient,
        antigen_administered_records: test_antigen_administered_records
      )
      expect(antigen_evaluator.evaluation_status).to eq('immune')
    end
    it 'automatically will evaluate not_complete for not complete' do
      not_complete_dates = create_valid_dates(test_patient.dob)[0..-2]
      vaccine_doses = create_patient_vaccines(test_patient, not_complete_dates)

      aars = AntigenAdministeredRecord.create_records_from_vaccine_doses(
        vaccine_doses
      )

      antigen_evaluator = AntigenEvaluator.new(
        antigen: test_antigen,
        patient: test_patient,
        antigen_administered_records: aars
      )
      expect(antigen_evaluator.evaluation_status).to eq('not_complete')
    end
  end
end
