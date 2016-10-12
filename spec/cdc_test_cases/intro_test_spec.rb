require 'rails_helper'

RSpec.describe 'CDC Tests' do
  before do
    new_time = Time.local(2016, 1, 3, 10, 0, 0)
    Timecop.freeze(new_time)
  end

  after do
    Timecop.return
  end

  describe 'cdc test 2013-0001' do
    before(:each) do
      test_number          = '2013-0001'
      test_case            = 'Newborn Testing'
      dob                  = '02/01/2012'
      gender               = 'f'
      patient_number       = test_number.split("-").join().to_i
      series_status        = 'Not Complete'
      forecast_number      = 1
      assesment_date       = '02/01/2012'
      evaluation_test_type = 'No Doses Administered'
      forecast_test_type   = 'Recommended based on age'
      earliest_date        = '03/14/2012'
      recommended_date     = '04/01/2012'
      past_due_date        = '05/28/2012'
      vaccine_group        = 'DTaP'
  # => !!? Is this true?
      overall_evaluation_status    = ''

      # patient_args = {
      #   dob: dob, gender: gender, address: "#{test_number} drive",
      #   city: 'San Francisco', state: 'CA', zip_code: '94103', cell_phone: '555-555-5555',
      #   first_name: 'Test', last_name: test_number
      # }
      patient_args = {
        dob: '02/12/2011',
        gender: 'f',
        address: "#{test_number} CDC Street",
        city: 'San Francisco',
        state: 'CA',
        zip_code: '94103',
        cell_phone: '555-555-5555',
        first_name: 'Test',
        last_name: test_number
      }


      @test_patient_20130001 = Patient.create_full_profile(patient_args)
    end
    it 'returns \'valid\' for #check_record' do
      expect(@test_patient_20130001.check_record).to eq('valid')
    end
  end

  describe 'cdc test 2013-0002' do
    before(:each) do
      test_number          = '2013-0002'
      test_case            = 'DTaP #2 at age 10 weeks-5 days'
      series_status        = 'Not Complete'
      forecast_number      = 2
      assesment_date       = '05/02/2011'
      evaluation_test_type = 'Age: Below Absolute Minimum'
      forecast_test_type   = 'Recommended based on age'
      earliest_date        = '05/30/2011'
      recommended_date     = '06/26/2011'
      past_due_date        = '08/22/2011'
      vaccine_group        = 'DTaP'


      patient_args = {
        dob: '02/26/2011',
        gender: 'f',
        address: "#{test_number} CDC Street",
        city: 'San Francisco',
        state: 'CA',
        zip_code: '94103',
        cell_phone: '555-555-5555',
        first_name: 'Test',
        last_name: test_number
      }

      vaccine_1 = {
        date_administered: '04/06/2011',
        vaccine_name: 'DTaP Unspecified',
        cvx_code: 107,
        evaluation_status: 'valid'
      }
      vaccine_2 = {
        date_administered: '05/02/2011',
        vaccine_name: 'DTaP Unspecified',
        cvx_code: 107,
        evaluation_status: 'not valid',
        evaulation_reason: 'Age: Too Young'
      }

      @test_patient_20130002 = Patient.create_full_profile(patient_args)

      vaccine_1_args = {
        patient_id: @test_patient_20130002.id,
        date_administered: vaccine_1[:date_administered],
        description: vaccine_1[:vaccine_name],
        cvx_code: vaccine_1[:cvx_code]
      }

      vaccine_2_args = {
        patient_id: @test_patient_20130002.id,
        date_administered: vaccine_2[:date_administered],
        description: vaccine_2[:vaccine_name],
        cvx_code: vaccine_1[:cvx_code]
      }

      @vaccine_dose_1        = VaccineDose.create(vaccine_1_args)
      @vaccine_dose_2        = VaccineDose.create(vaccine_2_args)
    end
    it 'returns \'valid\' for #check_record' do
      expect(@test_patient_20130002.check_record).to eq('valid')
    end
  end

end
