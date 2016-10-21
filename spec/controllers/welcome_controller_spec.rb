require 'rails_helper'

RSpec.describe WelcomeController, type: :controller do
  describe 'testing access credentials' do
    describe 'read requests' do
      it 'does not need a logged in user to visit' do
        get :index
        assert_response :success
      end
    end
  end
end
