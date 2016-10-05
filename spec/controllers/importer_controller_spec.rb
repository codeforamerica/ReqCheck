require 'rails_helper'

RSpec.describe ImporterController, type: :controller do
  describe 'POST import_patient_data' do
    let(:same_json) do
      {
        patient_data: [
          {
            patient_number: 01,
            first_name: 'Test',
            last_name: 'World',
            patient_number: ,
            dob: ,
            gender: ,
            race: ,
            home_phone: ,
            email: ,
            address: ,
            address2: ,
            city: ,
            state: ,
            zip_code: ,
          }
        ]
      }
    end

    it 'imports json with key \'patient_data\' and an array patients' do

    end

    it 'saves each new patient to the database' do
    end

    it 'updates each existing patient in the database' do
    end

    it 'saves the raw hash to the database if an error occurs' do
    end

    [
      'patient_id',
      'cvx_code',
      'date_administered',
      'hd_mpfile_updated_at'
    ].each do |patient_attr|
      it "requires a #{patient_attr}" do
      end
    end

    it 'creates new patient if patient_id is not found and logs error' do
    end

    it 'takes a json object with the key \'patient_data\'' do
      patient_data = { patient_data: 'made' }
      post :import_data, patient_data, format: :json
      expect(response.response_code).to eq(200)
      response_body = JSON.parse(response.body)
      expect(response_body['valid']).to eq('You betcha')
    end

    it 'imports an array of hashes with patient data in each hash' do


    end

  end
  describe 'POST import_vaccine_data' do
    let(:same_json) do
      {
        vaccine_data: [
          {
            patient_number: 01,
            first_name: 'Test',
            last_name: 'World',
            patient_number: ,
            dob: ,
            gender: ,
            race: ,
            home_phone: ,
            email: ,
            address: ,
            address2: ,
            city: ,
            state: ,
            zip_code: ,
          }
        ]
      }
    end

    it 'imports json with key \'vaccine_data\' and an array vaccine doses' do

    end

    it 'saves each vaccine dose to the database' do
      vaccine_data = { vaccine_data: 'made' }
      post :import_data, vaccine_data, format: :json
      expect(response.response_code).to eq(200)
      response_body = JSON.parse(response.body)
      expect(response_body['valid']).to eq('You betcha')
    end

    it 'saves the raw hash to the database if an error occurs' do
      vaccine_data = { vaccine_data: 'made' }
      post :import_data, vaccine_data, format: :json
      expect(response.response_code).to eq(200)
      response_body = JSON.parse(response.body)
      expect(response_body['valid']).to eq('You betcha')
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

    # it '#patients should 200 when visited with no search params' do
    #   get :index
    #   expect(response.response_code).to eq(200)
    # end

    # it '#patients should return no users with no search params' do
    #   get :index
    #   expect(assigns(:patients).length).to eq(0)
    # end
