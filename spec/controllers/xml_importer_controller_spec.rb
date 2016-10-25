require 'rails_helper'

RSpec.describe XMLImporterController, type: :controller do
  let(:staff) { FactoryGirl.create(:staff) }
  [
    :patch,
    :delete
  ].each do |action|
    it "rejects POST #{action}" do
      vaccine_dose_id = FactoryGirl.create(:vaccine_dose).id
      sign_in(staff)
      expect(action => "/vaccine_doses/#{vaccine_dose_id}").not_to be_routable
    end
  end
  describe 'the upload page' do
    it "rejects GET to '/xml' if user is not signed in" do
      get :index
      assert_response :success
    end
  end
end
