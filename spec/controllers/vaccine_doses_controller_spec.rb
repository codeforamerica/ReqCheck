require 'rails_helper'

RSpec.describe VaccineDosesController, type: :controller do
  let(:staff) { FactoryGirl.create(:staff) }
  before(:all) { FactoryGirl.create_list(:vaccine_dose, 5) }

  describe 'testing read methods do not exist' do
    it "rejects GET to '/vaccine_doses'" do
      sign_in(staff)
      expect(get: '/vaccine_doses').not_to be_routable
    end
    it "rejects GET to '/vaccine_doses/<id>'" do
      sign_in(staff)
      vaccine_dose_id = VaccineDose.first.id
      expect(get: "/vaccine_doses/#{vaccine_dose_id}").not_to be_routable
    end
  end

  describe 'testing write methods do not exist' do
    it "rejects POST to '/vaccine_doses'" do
      sign_in(staff)
      expect(post: '/vaccine_doses').not_to be_routable
    end

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
  end
end
