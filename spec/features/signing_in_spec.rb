# signing_in_spec.rb
require 'rails_helper'


feature 'Signing in' do
  scenario 'Successful sign in with admin' do
    FactoryGirl.create(:admin)

    visit '/'
    within '.header' do
      click_link 'Sign in'
    end

    fill_in 'Email', with: 'admin@admin.com'
    fill_in 'Password', with: 'password'
    click_on('Log in')

    expect(page).to have_current_path('/admin/dashboard')
    expect(page).to have_content('admin@admin.com')
    expect(page).to have_content('Dashboard')
    expect(page).to have_content('Signed in successfully.')
  end

  scenario 'Successful sign in with admin' do
    FactoryGirl.create(:staff)

    visit '/'
    within '.header' do
      click_link 'Sign in'
    end

    fill_in 'Email', with: 'staff@staff.com'
    fill_in 'Password', with: 'password'
    click_on('Log in')

    expect(page).to have_current_path('/patients')
    expect(page).to have_content('Search Patients')
  end
end

# Ensure sign in admin goes to admin homepage
# Ensure sign in staff goes to patients page
# Ensure signout goes to home page
#
# Ensure all pages are unavailable to non signed in users
# Ensure all admin pages are unavailable to staff
# Ensure all patients pages are available to admin
