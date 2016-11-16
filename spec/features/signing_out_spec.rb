# signing_out_spec.rb
require 'rails_helper'

feature 'Signing out' do
  context 'with a staff user' do
    scenario 'redirects a logged out person to the home page' do
      staff = FactoryGirl.create(:staff)
      login_as(staff)
      visit '/patients'

      expect(page).to have_current_path('/patients')

      within '.header' do
        click_link 'Sign out'
      end

      expect(page).to have_current_path('/')
      expect(page).to have_content('Welcome')

      visit '/patients'
      expect(page).to have_current_path('/users/sign_in')
    end
  end
  context 'with an admin user' do
    scenario 'redirects a logged out person to the home page' do
      admin = FactoryGirl.create(:admin)
      login_as(admin)
      visit '/admin'

      expect(page).to have_current_path('/admin')

      within '.header' do
        click_link 'Sign out'
      end

      expect(page).to have_current_path('/')
      expect(page).to have_content('Welcome')

      visit '/patients'
      expect(page).to have_current_path('/users/sign_in')
    end
  end
end
