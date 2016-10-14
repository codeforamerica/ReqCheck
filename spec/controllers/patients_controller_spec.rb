require 'rails_helper'

RSpec.describe PatientsController, type: :controller do
  describe 'GET index' do
    before(:each) do
      FactoryGirl.create_list(:patient, 5)
    end

    it '#patients should 302 redirect to patient show when given valid search params' do
      patient = FactoryGirl.create(:patient)
      get :index, search: patient
      expect(response.response_code).to eq(302)
    end

    it '#patients should return a list one patient with valid search params' do
      patient = FactoryGirl.create(:patient)
      get :index, search: patient
      expect(assigns(:patients).length).to eq(1)
      expect(assigns(:patients)[0].id).to eq(patient.id)
    end

    it '#patients should 200 when visited with no search params' do
      get :index
      expect(response.response_code).to eq(200)
    end

    it '#patients should return no users with no search params' do
      get :index
      expect(assigns(:patients).length).to eq(0)
    end
  end

  # Write controller test to ensure a logged out person will be redirected to home page

end
