require 'rails_helper'

RSpec.describe AntigenEvaluator, type: :model do
  before(:all) { FactoryGirl.create(:seed_antigen_xml) }
  after(:all) { DatabaseCleaner.clean_with(:truncation) }

  let(:test_antigen) { Antigen.find_by(target_disease: 'polio') }
  let(:test_patient) { FactoryGirl.create(:patient) }
  
  let(:test_vaccine_doses) do
    vax_doses = []
    vax_dates = [(test_patient.dob + 4.months), (test_patient.dob + 2.months)]
    vax_dates.each do |vax_date|
      vax_doses << FactoryGirl.create(:vaccine_dose,
                                      vaccine_code: 'POL',
                                      date_administered: vax_date,
                                      patient_profile: test_patient.patient_profile)
    end
    vax_doses
  end
  
  let(:test_antigen_administered_records) do 
    AntigenAdministeredRecord.create_records_from_vaccine_doses(test_vaccine_doses)
  end
  
  describe "validations" do
    it 'requires a patient object' do
      expect { AntigenEvaluator.new(antigen: test_antigen,
                                   antigen_administered_records: test_antigen_administered_records)
      }.to raise_exception(ArgumentError)
    end
    it 'requires an antigen object' do
      expect {
        AntigenEvaluator.new(patient: test_patient,
                             antigen_administered_records: test_antigen_administered_records)
      }.to raise_exception(ArgumentError)
    end
    it 'requires an array of antigen_administered_record object' do
      expect {
        AntigenEvaluator.new(antigen: test_antigen,
                             patient: test_patient)
      }.to raise_exception(ArgumentError)
    end
  end
  describe "relationships" do
    let(:antigen_evaluator) do 
      AntigenEvaluator.new(patient: test_patient,
                           antigen: test_antigen,
                           antigen_administered_records: test_antigen_administered_records)
    end
    it 'creates all patient series for the antigen' do
      expect(antigen_evaluator.patient_serieses.length).to eq(3)
      expect(antigen_evaluator.patient_serieses.first.class.name).to eq('PatientSeries')
    end
    it 'orders all patient series by preference number' do
      expect(antigen_evaluator.patient_serieses.map(&:preference_number)).to eq([1, 2, 3])
    end
    it 'orders all antigen_administered_records by date_administered' do
      records = antigen_evaluator.antigen_administered_records
      expect(records[0].date_administered < records[1].date_administered)
        .to eq(true)
    end
  end
end
