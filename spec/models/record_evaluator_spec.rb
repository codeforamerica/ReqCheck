require 'rails_helper'

RSpec.describe RecordEvaluator, type: :model do
  before(:all) do
    FactoryGirl.create(:seed_full_antigen_xml)
  end
  after(:all) do
    DatabaseCleaner.clean_with(:truncation)
  end

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

  def valid_2_year_test_patient(test_patient=nil)
    test_patient = test_patient || FactoryGirl.create(:patient_with_profile,
                                                      dob: 2.years.ago.to_date)
    required_vaccine_cvxs = [
      10, #'POL',
      110, #'DTHI',
      94 #'MMRV'
    ]
    valid_dates = create_valid_dates(test_patient.dob)[0..-2]
    required_vaccine_cvxs.each do |cvx_code|
      create_patient_vaccines(test_patient, valid_dates, cvx_code)
    end
    test_patient
  end

  def valid_5_year_test_patient(test_patient=nil)
    test_patient = test_patient || FactoryGirl.create(:patient_with_profile,
                                                      dob: 5.years.ago.to_date)
    required_vaccine_cvxs = [
      10, #'POL',
      110, #'DTHI',
      94 #'MMRV'
    ]
    valid_dates = create_valid_dates(test_patient.dob)
    required_vaccine_cvxs.each do |cvx_code|
      create_patient_vaccines(test_patient, valid_dates, cvx_code)
    end
    test_patient
  end

  let(:test_patient) { valid_5_year_test_patient }
  let(:record_evaluator) { RecordEvaluator.new(patient: test_patient) }

  describe 'validations' do
    it 'requires a patient object' do
      expect{RecordEvaluator.new}.to raise_exception(ArgumentError)
    end
  end

  describe 'relationships' do
    let(:record_evaluator) { RecordEvaluator.new(patient: test_patient) }

    it 'creates a patients antigen_administered_records' do
      expect(record_evaluator.antigen_administered_records.length).to eq(2)
      expect(record_evaluator.antigen_administered_records.first.class.name).to eq('AntigenAdministeredRecord')
    end
  end

  describe '#get_antigens' do
    it 'pulls all antigens from the database' do
      expect(record_evaluator.get_antigens.length).to eq(17)
    end
    it 'pulls only unique antigens from the database' do
      expect(record_evaluator.get_antigens.length).to eq(17)
      FactoryGirl.create(:antigen, target_disease: 'polio')
      expect(record_evaluator.get_antigens.length).to eq(17)
    end
  end

  describe '#create_all_antigen_evaluators' do
    let(:test_aars) do
      AntigenAdministeredRecord.create_records_from_vaccine_doses(
        test_patient.vaccine_doses
      )
    end
    let(:record_evaluator) { RecordEvaluator.new(patient: test_patient) }

    it 'creates all patient series for each antigen' do
      antigens = Antigen.all
      record_evaluator.create_all_antigen_evaluators(
        test_patient,
        antigens,
        test_aars
      )
      expect(record_evaluator.antigen_evaluators.length).to eq(17)
      expect(record_evaluator.antigen_evaluators.first.class.name)
        .to eq('AntigenEvaluator')
      expect(
        record_evaluator.antigen_evaluators
          .first.patient_serieses
          .first.class.name
      ).to eq('PatientSeries')
    end
  end


  describe '#record_evaluation' do
    it 'returns complete for an up to date patient' do
      record_evaluator = RecordEvaluator.new(
        patient: valid_2_year_test_patient
      )
      expect(record_evaluator.record_status).to eq('complete')
    end
    xit 'returns not_complete for a not up to date patient' do
    end
  end
end



# context 'with a child aged < 1 years' do
#   let(:test_patient_baby) { FactoryGirl.create(:patient_with_profile, dob: 10.months.ago) }

# end
# context 'with a child aged ~= 5 years' do
#   let(:test_patient_child) { FactoryGirl.create(:patient_with_profile, dob: 58.months.ago) }

# end
# context 'with a child aged ~= 12 years' do
#   let(:test_patient_child) { FactoryGirl.create(:patient_with_profile, dob: 12.years.ago) }

# end
# context 'with a child aged ~= 18 years' do
#   let(:test_patient_child) { FactoryGirl.create(:patient_with_profile, dob: 12.years.ago) }

# end
