require 'rails_helper'

RSpec.describe ImporterController, type: :controller do
  describe 'POST import_patient_data' do
    let(:same_json) do
      {
        json_data: [
          {
            patient_number: 01,
            first_name: 'Test',
            last_name: 'World',
            record_number: ,
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


    it 'takes a json object with the key \'json_data\'' do
      json_data = { json_data: 'made' }
      post :import_data, json_data, format: :json
      expect(response.response_code).to eq(200)
      response_body = JSON.parse(response.body)
      expect(response_body['valid']).to eq('You betcha')
    end

    it 'imports an array of hashes with patient data in each hash' do


    end

    # it '#patients should return a list one patient with valid search params' do
    #   patient = FactoryGirl.create(:patient_with_profile)
    #   get :index, search: patient.record_number
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
  end
end
