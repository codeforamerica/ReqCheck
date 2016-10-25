require 'rails_helper'

RSpec.describe PatientSeries, type: :model do
  include AntigenImporterSpecHelper

  before(:all) { seed_antigen_xml_polio }
  after(:all) { DatabaseCleaner.clean_with(:truncation) }

  let(:test_patient) { FactoryGirl.create(:patient) }

  let(:antigen_series) do
    Antigen.find_by(target_disease: 'polio').series.first
  end

  describe 'validations' do
    it 'takes a patient and antigen_series as parameters' do
      expect(
        PatientSeries.new(antigen_series: antigen_series,
                       patient: test_patient).class.name
      ).to eq('PatientSeries')
    end

    it 'requires a patient object' do
      expect{PatientSeries.new(antigen_series: antigen_series)}.to raise_exception
    end
    it 'requires an antigen_series' do
      expect{PatientSeries.new(patient: test_patient)}.to raise_exception
    end

    it 'automatically calls #create_target_doses' do
      expect(
        PatientSeries.new(antigen_series: antigen_series,
                          patient: test_patient).target_doses.length
      ).not_to eq(0)
    end
  end

  describe 'patient_series attributes from the antigen_series' do
    let(:test_patient_series) do
      PatientSeries.new(antigen_series: antigen_series, patient: test_patient)
    end

    dose_attributes = [
      'name', 'target_disease', 'vaccine_group', 'default_series',
      'product_path', 'preference_number', 'min_start_age', 'max_start_age'
    ]

    dose_attributes.each do | dose_attribute |
      it "has the attribute #{dose_attribute}" do
        expect(test_patient_series.antigen_series).not_to eq(nil)
        expect(test_patient_series.send(dose_attribute))
          .to eq(antigen_series.send(dose_attribute))
      end
    end
  end

  describe '#pull_eligible_target_doses' do
    let(:test_patient_2_years) do
      FactoryGirl.create(:patient, dob: 2.years.ago)
    end

    let(:test_patient_series) do
      PatientSeries.new(antigen_series: antigen_series,
                        patient: test_patient_2_years)
    end

    describe 'it checks min age requirements' do
      it 'loops through the target doses and evaluates if the patient is eligible by birthday' do
        target_doses = test_patient_series.target_doses
        eligible_target_doses =
          test_patient_series.pull_eligible_target_doses(target_doses)
        expect(eligible_target_doses).to eq(test_patient_series.target_doses[0...-1])
      end
      it 'will return the dose if there is no min_age requirement' do
        target_doses      = test_patient_series.target_doses
        target_doses[-1].antigen_series_dose.min_age = nil
        eligible_target_doses =
          test_patient_series.pull_eligible_target_doses(target_doses)
        expect(eligible_target_doses).to eq(test_patient_series.target_doses)
      end
    end
    describe 'it checks max age requirements' do
      it 'pulls ineligible target doses out' do
        test_patient_20_years = FactoryGirl.create(:patient, dob: 20.years.ago).patient
        test_patient_series   = PatientSeries.new(antigen_series: antigen_series,
                                                  patient: test_patient_20_years)
        target_doses = test_patient_series.target_doses
        eligible_target_doses =
          test_patient_series.pull_eligible_target_doses(target_doses)
        expect(eligible_target_doses).to eq([])
      end
      it 'will return dose if no max_age requirement' do
        test_patient_20_years = FactoryGirl.create(:patient, dob: 20.years.ago).patient
        test_patient_series   = PatientSeries.new(antigen_series: antigen_series,
                                                  patient: test_patient_20_years)
        target_doses = test_patient_series.target_doses
        target_doses[0].antigen_series_dose.max_age = nil
        eligible_target_doses =
          test_patient_series.pull_eligible_target_doses(target_doses)
        expect(eligible_target_doses).to eq([target_doses[0]])
      end
    end
    it 'will error if the target_doses are not in order' do
        target_doses = test_patient_series.target_doses
        target_doses = target_doses[1..-1]
        expect{
          test_patient_series.pull_eligible_target_doses(target_doses)
        }.to raise_exception(StandardError)
    end
  end

  # describe '#evaluate_target_dose' do
  #   it 'compares itself against the antigen_administered_record' do


  #   end

  #   it 'sets ineligible to true if the patient is not eligible for the target_dose' do

  #   end
  # end

  describe '#evaluate_patient_series' do
    context 'when the patient could be immune' do
      let(:test_patient_5_years) do
        FactoryGirl.create(:patient,
                           dob: 5.years.ago.to_date).patient
      end

      let(:patient_series_5_years) do
        antigen = Antigen.find_by(target_disease: 'polio')
        PatientSeries.create_antigen_patient_serieses(
          antigen: antigen,
          patient: test_patient_5_years
        ).first
      end

      let(:vaccine_doses_complete) do
        start_date = test_patient_5_years.dob
        [
          (start_date + 6.weeks).to_date,
          (start_date + 10.weeks).to_date,
          (start_date + 14.weeks).to_date,
          (1.year.ago).to_date,
        ].map do |date_admin|
          FactoryGirl.create(:vaccine_dose_by_cvx,
                             cvx_code: 10,
                             patient: test_patient_5_years,
                             date_administered: date_admin)
        end
      end
      let(:vaccine_doses_not_complete) do
        start_date = test_patient_5_years.dob
        [
          (start_date + 6.weeks).to_date,
          (start_date + 10.weeks).to_date,
          (start_date + 14.weeks).to_date
        ].map do |date_admin|
          FactoryGirl.create(:vaccine_dose_by_cvx,
                             cvx_code: 10,
                             patient: test_patient_5_years,
                             date_administered: date_admin)
        end
      end
      let(:vaccine_doses_invalid_age) do
        start_date = test_patient_5_years.dob
        [
          (start_date + 3.weeks).to_date,
          (start_date + 10.weeks).to_date,
          (start_date + 14.weeks).to_date,
          (1.year.ago).to_date,
        ].map do |date_admin|
          FactoryGirl.create(:vaccine_dose_by_cvx,
                             cvx_code: 10,
                             patient: test_patient_5_years,
                             date_administered: date_admin)
        end
      end
      it 'returns immune if the patient is up to date and no other target_doses' do
        aars = AntigenAdministeredRecord.create_records_from_vaccine_doses(
          vaccine_doses_complete
        )
        evaluation = patient_series_5_years.evaluate_patient_series(
          aars
        )
        expect(evaluation).to eq('immune')
      end
      it 'returns not_complete if the patient is not up to date' do
        aars = AntigenAdministeredRecord.create_records_from_vaccine_doses(
          vaccine_doses_not_complete
        )
        evaluation = patient_series_5_years.evaluate_patient_series(
          aars
        )
        expect(evaluation).to eq('not_complete')
      end
      it 'returns not_complete if a vaccine age is invalid' do
        aars = AntigenAdministeredRecord.create_records_from_vaccine_doses(
          vaccine_doses_invalid_age
        )
        evaluation = patient_series_5_years.evaluate_patient_series(
          aars
        )
        expect(evaluation).to eq('not_complete')
      end
    end
    context 'when the patient cant be immune' do
      let(:test_patient_3_years) do
        FactoryGirl.create(:patient,
                           dob: 3.years.ago.to_date).patient
      end

      let(:patient_series_3_years) do
        antigen = Antigen.find_by(target_disease: 'polio')
        PatientSeries.create_antigen_patient_serieses(
          antigen: antigen,
          patient: test_patient_3_years
        ).first
      end

      let(:vaccine_doses_complete) do
        start_date = test_patient_3_years.dob
        [
          (start_date + 6.weeks).to_date,
          (start_date + 10.weeks).to_date,
          (start_date + 14.weeks).to_date
        ].map do |date_admin|
          FactoryGirl.create(:vaccine_dose_by_cvx,
                             cvx_code: 10,
                             patient: test_patient_3_years,
                             date_administered: date_admin)
        end
      end
      let(:vaccine_doses_not_complete) do
        start_date = test_patient_3_years.dob
        [
          (start_date + 6.weeks).to_date,
          (start_date + 10.weeks).to_date
        ].map do |date_admin|
          FactoryGirl.create(:vaccine_dose_by_cvx,
                             cvx_code: 10,
                             patient: test_patient_3_years,
                             date_administered: date_admin)
        end
      end
      let(:vaccine_doses_invalid_age) do
        start_date = test_patient_3_years.dob
        [
          (start_date + 2.weeks).to_date,
          (start_date + 10.weeks).to_date,
          (start_date + 12.weeks).to_date
        ].map do |date_admin|
          FactoryGirl.create(:vaccine_dose_by_cvx,
                             cvx_code: 10,
                             patient: test_patient_3_years,
                             date_administered: date_admin)
        end
      end

      it 'returns complete if the patient is up to date' do
        aars = AntigenAdministeredRecord.create_records_from_vaccine_doses(
          vaccine_doses_complete
        )
        evaluation = patient_series_3_years.evaluate_patient_series(
          aars
        )
        expect(evaluation).to eq('complete')
      end
      it 'returns not_complete if the patient is not up to date' do
        aars = AntigenAdministeredRecord.create_records_from_vaccine_doses(
          vaccine_doses_not_complete
        )
        evaluation = patient_series_3_years.evaluate_patient_series(
          aars
        )
        expect(evaluation).to eq('not_complete')
      end
      it 'returns not_complete if a vaccine age is invalid' do
        aars = AntigenAdministeredRecord.create_records_from_vaccine_doses(
          vaccine_doses_invalid_age
        )
        evaluation = patient_series_3_years.evaluate_patient_series(
          aars
        )
        expect(evaluation).to eq('not_complete')
      end

      it 'sets \'unsatisfied_target_dose\' to the target dose not completed' do
        aars = AntigenAdministeredRecord.create_records_from_vaccine_doses(
          vaccine_doses_not_complete
        )
        expected_target_dose = patient_series_3_years.target_doses.find do |td|
          td.antigen_series_dose.id == 3
        end
        evaluation = patient_series_3_years.evaluate_patient_series(
          aars
        )
        expect(patient_series_3_years.unsatisfied_target_dose)
          .to eq(expected_target_dose)
      end
    end


  end

  describe '.create_antigen_patient_serieses' do
    let(:antigen) { Antigen.find_by(target_disease: 'polio') }

    it 'takes a patient and antigen and creates an array of patient_series objects' do
      patient_series = PatientSeries.create_antigen_patient_serieses(antigen: antigen,
                                                                     patient: test_patient)
      expect(patient_series.length).to eq(3)
      expect(patient_series.first.class.name).to eq('PatientSeries')
      expect(patient_series.length).to eq(antigen.series.length)
    end
    it 'returns the patient_serieses in the order of the preference_number' do
      patient_series = PatientSeries.create_antigen_patient_serieses(antigen: antigen,
                                                                     patient: test_patient)
      expect(patient_series.map(&:preference_number)).to eq([1, 2, 3])
    end
  end
end
