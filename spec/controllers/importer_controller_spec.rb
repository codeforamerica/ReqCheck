require 'rails_helper'

RSpec.describe ImporterController, type: :controller do
  before(:each) do
    FactoryGirl.create(:patient_with_profile,
                       dob: 3.years.ago,
                       patient_number: 4)
    FactoryGirl.create(:patient_with_profile,
                       dob: 5.years.ago,
                       patient_number: 5)
    FactoryGirl.create(:patient_with_profile,
                       dob: 7.years.ago,
                       patient_number: 6)
  end
  after(:each) do
    DatabaseCleaner.clean_with(:truncation)
  end

  describe 'POST import_patient_data' do
    let(:valid_patient_json) do
      {
        patient_data: [
          {
            patient_number: 4,
            first_name: 'Test1',
            last_name: 'Tester1',
            dob: 3.years.ago,
            home_phone: '555-555-1212',
            email: 'newemail@example.com',
            hd_mpfile_updated_at: DateTime.now
          },
          {
            patient_number: 5,
            first_name: 'Test2',
            last_name: 'Tester2',
            dob: 4.years.ago,
            hd_mpfile_updated_at: DateTime.now
          },
          {
            patient_number: 6,
            dob: 5.years.ago,
            first_name: 'Test3',
            last_name: 'Test4',
            home_phone: '555-555-1212',
            email: 'newemail@example.com',
            address: '7 Kings Lane',
            city: 'San Francisco',
            state: 'CA',
            zip_code: '03406',
            hd_mpfile_updated_at: DateTime.now
          }
        ]
      }
    end

    it 'imports json with key \'patient_data\' and an array patients' do
      post :import_patient_data, valid_patient_json, format: :json
      expect(response.response_code).to eq(201)

      expect(Patient.find_by_patient_number(4).home_phone)
        .to eq('555-555-1212')
      expect(Patient.find_by_patient_number(5).dob).to eq(4.years.ago.to_date)
      expect(Patient.find_by_patient_number(6).address).to eq('7 Kings Lane')
    end

    it 'saves each new patient to the database' do
      patient_json = valid_patient_json
      patient_json[:patient_data] << {
        patient_number: 1,
        first_name: 'New',
        last_name: 'Patient',
        dob: 10.years.ago,
        hd_mpfile_updated_at: DateTime.now
      }

      post :import_patient_data, patient_json, format: :json
      expect(response.response_code).to eq(201)
      response_body = JSON.parse(response.body)
      expect(response_body['status']).to eq('success')

      patient = Patient.find_by_patient_number(1)
      expect(patient.first_name).to eq('New')
    end

    it 'updates each existing patient in the database' do
      expect(Patient.find_by_patient_number(4).home_phone).to eq(nil)
      expect(Patient.find_by_patient_number(5).dob).to eq(5.years.ago.to_date)
      expect(Patient.find_by_patient_number(6).address).to eq(nil)

      post :import_patient_data, valid_patient_json, format: :json
      expect(response.response_code).to eq(201)

      expect(Patient.find_by_patient_number(4).home_phone)
        .to eq('555-555-1212')
      expect(Patient.find_by_patient_number(5).dob).to eq(4.years.ago.to_date)
      expect(Patient.find_by_patient_number(6).address).to eq('7 Kings Lane')
    end

    it 'saves the raw hash to the database if an error occurs' do
      patient_data = {
        patient_data: [
          {
            patient_number: -14,
            first_name: 'Shouldnot',
            last_name: 'Work',
            dob: 3.years.ago
          }
        ]
      }
      post :import_patient_data, patient_data, format: :json
      expect(response.response_code).to eq(201)
      response_body = JSON.parse(response.body)
      expect(response_body['status']).to eq('partial_failure')
      expect(response_body['error_objects_ids']).to eq([1])
    end

    it 'saves multiple error raw hashes if multiple errors occur' do
      patient_data = {
        patient_data: [
          {
            patient_number: -14,
            first_name: 'Shouldnot',
            last_name: 'Work',
            dob: 3.years.ago,
            hd_mpfile_updated_at: DateTime.now
          },
          {
            patient_number: 19,
            first_name: 'Shouldnot',
            last_name: 'Work2',
            dob: 3.years.ago,
            hd_mpfile_updated_at: DateTime.now,
            extra: 'field'
          }
        ]
      }
      post :import_patient_data, patient_data, format: :json
      expect(response.response_code).to eq(201)
      response_body = JSON.parse(response.body)
      expect(response_body['status']).to eq('partial_failure')
      expect(response_body['error_objects_ids']).to eq([2, 3])
    end

    %w(patient_number first_name last_name dob
       hd_mpfile_updated_at).each.with_index do |patient_attr, index|
      patient_json = {
        patient_data: [
          {
            patient_number: 4,
            first_name: 'Test0',
            last_name: 'Tester0',
            dob: 3.years.ago,
            hd_mpfile_updated_at: DateTime.now
          }
        ]
      }
      it "requires a #{patient_attr}" do
        patient_json[:patient_data].first.delete(patient_attr.to_sym)
        post :import_patient_data, patient_json, format: :json
        expect(response.response_code).to eq(201)
        response_body = JSON.parse(response.body)
        expect(response_body['status']).to eq('partial_failure')
        expect(response_body['error_objects_ids']).to eq([(index + 4)])
      end
    end

    it 'returns an error if there are additional, unrecognizable parameters' do
      patient_json = {
        patient_data: [
          {
            patient_number: 4,
            first_name: 'Bad',
            last_name: 'Test',
            dob: 3.years.ago,
            hd_mpfile_updated_at: DateTime.now,
            random_attr: 'Not allowed'
          }
        ]
      }
      post :import_patient_data, patient_json, format: :json
      expect(response.response_code).to eq(201)
      response_body = JSON.parse(response.body)
      expect(response_body['status']).to eq('partial_failure')
      expect(response_body['error_objects_ids']).to eq([9])
    end
  end
  describe 'POST import_vaccine_data' do
    # let(:same_json) do
    #   {
    #     vaccine_data: [
    #       {
    #         patient_number: 01,
    #         first_name: 'Test',
    #         last_name: 'World',
    #         patient_number: ,
    #         dob: ,
    #         gender: ,
    #         race: ,
    #         home_phone: ,
    #         email: ,
    #         address: ,
    #         address2: ,
    #         city: ,
    #         state: ,
    #         zip_code: ,
    #       }
    #     ]
    #   }
    # end

    it 'imports json with key \'vaccine_data\' and an array vaccine doses' do

    end

    it 'saves each vaccine dose to the database' do
      vaccine_data = { vaccine_data: 'made' }
      post :import_data, vaccine_data, format: :json
      expect(response.response_code).to eq(201)
      response_body = JSON.parse(response.body)
      expect(response_body['status']).to eq('You betcha')
    end

    it 'saves the raw hash to the database if an error occurs' do
      vaccine_data = { vaccine_data: 'made' }
      post :import_data, vaccine_data, format: :json
      expect(response.response_code).to eq(201)
      response_body = JSON.parse(response.body)
      expect(response_body['status']).to eq('You betcha')
    end

    [
      'patient_id',
      'cvx_code',
      'date_administered',
      'hd_imfile_updated_at'
    ].each do |vaccine_attr|
      it "requires a #{vaccine_attr}" do
      end
    end

    it 'creates new patient if patient_id is not found and logs error' do
    end
  end
end




    # it '#patients should return a list one patient with valid search params' do
    #   patient = FactoryGirl.create(:patient_with_profile)
    #   get :index, search: patient.patient_number
    #   expect(assigns(:patients).length).to eq(1)
    #   expect(assigns(:patients)[0].id).to eq(patient.id)
    # end

    # it '#patients should 201 when visited with no search params' do
    #   get :index
    #   expect(response.response_code).to eq(201)
    # end

    # it '#patients should return no users with no search params' do
    #   get :index
    #   expect(assigns(:patients).length).to eq(0)
    # end
