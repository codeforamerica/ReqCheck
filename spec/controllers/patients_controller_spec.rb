require 'rails_helper'

RSpec.describe PatientsController, type: :controller do
  let(:staff) { FactoryGirl.create(:staff) }
  before(:all) { FactoryGirl.create_list(:patient, 5) }

  describe 'testing access credentials' do
    describe 'read requests' do
      [
        :index,
        :show
      ].each do |action|
        it "rejects GET #{action} with no sign in and redirects" do
          if action == :show
            get action, id: Patient.first
          else
            get action
          end
          expect(response.response_code).to eq(302)
          expect(response).to redirect_to(new_user_session_path)
        end
        it "rejects GET #{action} after signing out" do
          sign_in(staff)
          if action == :show
            get action, id: Patient.first
          else
            get action
          end
          expect(response.response_code).to eq(200)
          expect(response.response_code).to render_template(action)

          # Second call after logged out
          sign_out(staff)
          if action == :show
            get action, id: Patient.first
          else
            get action
          end
          expect(response.response_code).to eq(302)
          expect(response).to redirect_to(new_user_session_path)
        end
      end
    end
  end

  describe 'testing that write methods do not exist' do
    it "rejects POST to '/patients'" do
      sign_in(staff)
      expect(post: '/patients').not_to be_routable
    end

    [
      :patch,
      :delete
    ].each do |action|
      it "rejects POST #{action} with no sign in and redirects" do
        patient_id = FactoryGirl.create(:patient).id
        sign_in(staff)
        expect(action => "/patients/#{patient_id}").not_to be_routable
      end
    end
  end

  describe 'GET index' do
    before(:each) do
      sign_in staff
    end

    it '#patients 302 redirects to patient show with valid search params' do
      patient = FactoryGirl.create(:patient)
      get :index, search: patient.patient_number
      expect(response.response_code).to eq(302)
    end

    it '#patients returns a list one patient with valid search params' do
      patient = FactoryGirl.create(:patient)
      get :index, search: patient.patient_number
      expect(assigns(:patients).length).to eq(1)
      expect(assigns(:patients)[0].id).to eq(patient.id)
    end

    it '#patients 200 when visited with no search params' do
      get :index
      expect(response.response_code).to eq(200)
    end

    it '#patients returns no users with no search params' do
      get :index
      expect(assigns(:patients).length).to eq(0)
    end
  end

  # Write controller test to ensure a logged out person will be redirected to home page
  # Write controller spec to ensure that a new patient cannot be created
  # Write controller spec to ensure that a logged in person cannot update a patient profile
end
