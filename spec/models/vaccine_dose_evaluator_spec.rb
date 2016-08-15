require 'rails_helper'

RSpec.describe VaccineDoseEvaluator, type: :model do
  before(:all) { FactoryGirl.create(:seed_antigen_xml) }
  after(:all) { DatabaseCleaner.clean_with(:truncation) }


  # Creates a test patient with two vaccine doses
  let(:test_patient) do
    test_patient = FactoryGirl.create(:patient) 
    FactoryGirl.create(:vaccine_dose, patient_profile: test_patient.patient_profile, vaccine_code: "IPV", date_administered: (test_patient.dob + 7.weeks))
    FactoryGirl.create(:vaccine_dose, patient_profile: test_patient.patient_profile, vaccine_code: "IPV", date_administered: (test_patient.dob + 11.weeks))
    test_patient.reload
    test_patient
  end
  
  # Pulls a polio antigen series dose
  let(:as_dose) do
    AntigenSeriesDose.joins(:antigen_series).joins('INNER JOIN "antigens" ON "antigens"."id" = "antigen_series"."antigen_id"').where(antigens: {target_disease: 'polio'}).first
  end

  # Creates a target_dose with the antigen_series_dose and test_patient
  let(:test_target_dose) do
    TargetDose.new(antigen_series_dose: as_dose, patient: test_patient)
  end

  # Creates antigen_administered_record based on 
  let(:test_antigen_administered_record) do
    AntigenAdministeredRecord.create_records_from_vaccine_doses(
      [test_patient.vaccine_doses.first]
    ).first
  end


  describe 'validations' do
    it 'requires a target_dose and antigen_administered_record' do
      evaluator = VaccineDoseEvaluator.new(
                    target_dose: test_target_dose,
                    antigen_administered_record: test_antigen_administered_record
                  )
      expect(evaluator.class.name).to eq('VaccineDoseEvaluator')
    end
    it 'raises an argument error if missing a target_dose' do
      expect{
        VaccineDoseEvaluator.new(antigen_administered_record: test_antigen_administered_record)
      }.to raise_exception(ArgumentError)
    end
    it 'raises an argument error if missing an antigen_administered_record' do
      expect{
        VaccineDoseEvaluator.new(target_dose: test_target_dose)
      }.to raise_exception(ArgumentError)
    end
  end


  describe '#evaluate_dose_administered_condition' do
    it 'evaluates the dose administered condition and returns ______' do

    end

  end

end
