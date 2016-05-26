require 'rails_helper'

RSpec.describe PatientsController, type: :controller do
  describe "GET index" do
    before(:each) do
      FactoryGirl.create_list(:patient, 5)
    end


    it '#patients should 200 when visited with valid search params' do
      patient = FactoryGirl.create(:patient)
      get :index, search: patient.record_number
      expect(response.response_code).to eq(200)
    end

    it '#patients should return a list one patient with valid search params' do
      patient = FactoryGirl.create(:patient)
      get :index, search: patient.record_number
      expect(assigns(:patients).length).to eq(1)
      expect(assigns(:patients)[0].id).to eq(patient.id)
    end

    it '#patients should 200 when visited with no search params' do
      get :index
      expect(response.response_code).to eq(200)
    end

    it '#patients should return all users with no search params' do
      get :index
      expect(assigns(:patients).length).to eq(5)
      expect(assigns(:patients)[0].class.name).to eq('Patient')
    end
      
  end
end
