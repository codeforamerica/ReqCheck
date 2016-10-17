require 'rails_helper'

RSpec.describe HeartbeatController, type: :controller do
  before(:each) do
    FactoryGirl.create(:vaccine_dose_data_import)
    FactoryGirl.create(:patient_data_import)
    FactoryGirl.create(:vaccine_dose_data_import_error)
    FactoryGirl.create(:patient_data_import_error)
  end
  after(:each) do
    DatabaseCleaner.clean_with(:truncation)
  end

  describe 'GET heartbeat' do
    it 'gives the patient_data_import created_at datetime when older' do
      patient_import = FactoryGirl.create(:patient_data_import)
      FactoryGirl.create(:vaccine_dose_data_import)

      get :heartbeat
      expect(response.response_code).to eq(200)
      response_body = JSON.parse(response.body)
      response_body_time = DateTime.parse(response_body['last_update_date'])
      patient_import_time = patient_import.created_at
      expect(response_body_time.to_i).to eq(patient_import_time.to_i)
    end
    it 'gives the vaccine_dose_data_import created_at datetime when older' do
      vaccine_dose_import = FactoryGirl.create(:vaccine_dose_data_import)
      FactoryGirl.create(:patient_data_import)

      get :heartbeat
      expect(response.response_code).to eq(200)
      response_body = JSON.parse(response.body)
      response_body_time = DateTime.parse(response_body['last_update_date'])
      vaccine_dose_import_time = vaccine_dose_import.created_at
      expect(response_body_time.to_i).to eq(vaccine_dose_import_time.to_i)
    end
  end
end
