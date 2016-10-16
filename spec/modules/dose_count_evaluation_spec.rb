require 'rails_helper'

RSpec.describe DoseCountEvaluation do
  include PatientSpecHelper
  include AntigenImporterSpecHelper

  before(:all) { seed_antigen_xml_polio }
  after(:all) { DatabaseCleaner.clean_with(:truncation) }

  let(:test_object) do
    class TestClass
      include DoseCountEvaluation
    end
    TestClass.new
  end

  let(:test_patient) do
    test_patient = FactoryGirl.create(:patient)
    # These vaccines are will evaluate to valid dose to skip as it is past
    # 4 years and the interval is more than 6 months as noted in
    # conditional_skip_set set_description
    FactoryGirl.create(
      :vaccine_dose,
      patient: test_patient,
      vaccine_code: 'IPV',
      date_administered: (test_patient.dob + 5.years)
    )
    FactoryGirl.create(
      :vaccine_dose,
      patient: test_patient,
      vaccine_code: 'IPV',
      date_administered: (test_patient.dob + 6.years)
    )
    test_patient.reload
    test_patient
  end

  describe '#match_vaccine_doses_with_cvx_codes' do
    let(:cvx_polio) { [10, 110, 120] }
    let(:cvx_non_polio) { [162, 133, 85] }
    let(:all_vaccine_doses) do
      cvx_codes = [cvx_polio, cvx_non_polio].flatten
      vaccine_doses = []
      cvx_codes.each_with_index do |cvx_code, index|
        vax_code = TextVax.find_all_vax_codes_by_cvx(cvx_code).first
        vaccine_doses << FactoryGirl.create_list(
          :vaccine_dose,
          (index + 1),
          vaccine_code: vax_code,
          patient: test_patient
        )
      end
      vaccine_doses.flatten
    end
    it 'pulls all vaccine_doses that match the cvx_codes' do
      polio_vaccine_doses =
        test_object.match_vaccine_doses_with_cvx_codes(
          all_vaccine_doses,
          cvx_polio
        )
      expect(polio_vaccine_doses.length).to eq(6)
      expect(polio_vaccine_doses.first.class.name).to eq('VaccineDose')
    end
    it 'returns an empty array if the cvx_codes is empty' do
      polio_vaccine_doses =
        test_object.match_vaccine_doses_with_cvx_codes(
          all_vaccine_doses,
          []
        )
      expect(polio_vaccine_doses.length).to eq(0)
    end
    it 'returns an empty array if there are no vaccines that match' do
      polio_vaccine_doses =
        test_object.match_vaccine_doses_with_cvx_codes(
          all_vaccine_doses,
          [12, 13, 14, 15]
        )
      expect(polio_vaccine_doses.length).to eq(0)
    end
  end
  describe '#calculate_count_of_vaccine_doses' do
    let(:cvx_polio) { [10, 110, 120] }
    let(:cvx_non_polio) { [162, 133, 85] }
    let(:valid_vaccine_types) do
      [1, 10, 22, 50, 102, 106, 107, 110, 115, 120, 130, 132, 146]
    end
    let(:test_condition_object) do
      FactoryGirl.create(
        :conditional_skip_condition,
        begin_age: '3 years - 4 days',
        condition_type: 'vaccine count by age',
        dose_type: 'valid',
        vaccine_types: valid_vaccine_types.join(';')
      )
    end
    let(:all_vaccine_doses) do
      cvx_codes = [cvx_polio, cvx_non_polio].flatten
      vaccine_doses = []
      cvx_codes.each_with_index do |cvx_code, index|
        vax_code = TextVax.find_all_vax_codes_by_cvx(cvx_code).first
        vaccine_doses << FactoryGirl.create_list(
          :vaccine_dose,
          (index + 1),
          vaccine_code: vax_code,
          patient: test_patient
        )
      end
      vaccine_doses.flatten
    end

    it 'it includes only vaccines from the list of vaccine types' do
      expect(all_vaccine_doses.length).to eq(21)
      same_vaccine_types = all_vaccine_doses.select do |vaccine_dose|
        valid_vaccine_types.include?(vaccine_dose.cvx_code)
      end
      expect(same_vaccine_types.length).to eq(6)
      expect(
        test_object.calculate_count_of_vaccine_doses(
          all_vaccine_doses,
          test_condition_object.vaccine_types
        )
      ).to eq(6)
    end

    it 'it includes only vaccines given after the begin_age' do
      expect(test_condition_object.begin_age).to eq('3 years - 4 days')
      patient = all_vaccine_doses.first.patient
      begin_age_date = patient.dob + 3.years - 4.days
      test_vaccine_doses = [FactoryGirl.create(
        :vaccine_dose_by_cvx,
        patient: patient,
        cvx_code: 10,
        date_administered: (patient.dob + 4.years)
      )]
      test_vaccine_doses << FactoryGirl.create(
        :vaccine_dose_by_cvx,
        patient: patient,
        cvx_code: 10,
        date_administered: (patient.dob + 2.years)
      )
      expect(
        test_object.calculate_count_of_vaccine_doses(
          test_vaccine_doses,
          test_condition_object.vaccine_types,
          begin_age_date: begin_age_date
        )
      ).to eq(1)
    end

    it 'it includes only vaccines given before the end_age' do
      patient = all_vaccine_doses.first.patient
      end_age_date = patient.dob + 4.years
      test_vaccine_doses = [FactoryGirl.create(
        :vaccine_dose_by_cvx,
        patient: patient,
        cvx_code: 10,
        date_administered: (patient.dob + 5.years)
      )]
      test_vaccine_doses << FactoryGirl.create(
        :vaccine_dose_by_cvx,
        patient: patient,
        cvx_code: 10,
        date_administered: (patient.dob + 2.years)
      )
      test_vaccine_doses << FactoryGirl.create(
        :vaccine_dose_by_cvx,
        patient: patient,
        cvx_code: 10,
        date_administered: (patient.dob + 3.years)
      )
      expect(
        test_object.calculate_count_of_vaccine_doses(
          test_vaccine_doses,
          test_condition_object.vaccine_types,
          end_age_date: end_age_date
        )
      ).to eq(2)
    end
    it 'it includes only vaccines given after the start_date' do
      patient = all_vaccine_doses.first.patient
      start_date = Date.today - 3.months
      test_vaccine_doses = [FactoryGirl.create(
        :vaccine_dose_by_cvx,
        patient: patient,
        cvx_code: 10,
        date_administered: (Date.today - 2.months)
      )]
      test_vaccine_doses << FactoryGirl.create(
        :vaccine_dose_by_cvx,
        patient: patient,
        cvx_code: 10,
        date_administered: (Date.today - 4.months)
      )
      test_vaccine_doses << FactoryGirl.create(
        :vaccine_dose_by_cvx,
        patient: patient,
        cvx_code: 10,
        date_administered: (Date.today - 6.months)
      )
      expect(
        test_object.calculate_count_of_vaccine_doses(
          test_vaccine_doses,
          test_condition_object.vaccine_types,
          start_date: start_date
        )
      ).to eq(1)
    end
    it 'it includes only vaccines given before the end_date' do
      patient = all_vaccine_doses.first.patient
      end_date = Date.today - 3.months
      test_vaccine_doses = [FactoryGirl.create(
        :vaccine_dose_by_cvx,
        patient: patient,
        cvx_code: 10,
        date_administered: (Date.today - 2.months)
      )]
      test_vaccine_doses << FactoryGirl.create(
        :vaccine_dose_by_cvx,
        patient: patient,
        cvx_code: 10,
        date_administered: (Date.today - 4.months)
      )
      test_vaccine_doses << FactoryGirl.create(
        :vaccine_dose_by_cvx,
        patient: patient,
        cvx_code: 10,
        date_administered: (Date.today - 6.months)
      )
      expect(
        test_object.calculate_count_of_vaccine_doses(
          test_vaccine_doses,
          test_condition_object.vaccine_types,
          end_date: end_date
        )
      ).to eq(2)
    end

    # context 'when dose_type is \'Valid\'' do
    #   it 'returns an empty array if the cvx_codes is empty' do
    #     polio_vaccine_doses =
    #       test_object.match_vaccine_doses_with_cvx_codes(
    #         all_vaccine_doses,
    #         []
    #       )
    #     expect(polio_vaccine_doses.length).to eq(0)
    #   end
    #   it 'returns an empty array if there are no vaccines that match' do
    #     polio_vaccine_doses =
    #       test_object.match_vaccine_doses_with_cvx_codes(
    #         all_vaccine_doses,
    #         [12, 13, 14, 15]
    #       )
    #     expect(polio_vaccine_doses.length).to eq(0)
    #   end
    # end
  end
  describe '#evaluate_vaccine_dose_count' do
    dose_count_hash = {
      'greater than' => [false, false, true],
      'equals' => [false, true, false],
      'less than' => [true, false, false]
    }
    dose_counts = [4, 5, 6]
    required_dose_count = 5
    dose_count_hash.each do |dose_count_logic, values|
      dose_counts.each_with_index do |actual_dose_count, index|
        expected_return_value = values[index]
        it "returns #{expected_return_value} for logic #{dose_count_logic} " \
           "with a required_dose_count of #{required_dose_count} and " \
           "actual dose count of #{actual_dose_count}" do
          result = test_object.evaluate_vaccine_dose_count(
            dose_count_logic,
            required_dose_count,
            actual_dose_count
          )
          expect(result).to eq(expected_return_value)
        end
      end
    end
  end
end
