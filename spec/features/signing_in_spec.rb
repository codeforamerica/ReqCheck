# signing_in_spec.rb
require 'rails_helper'

# Ensure that sign in is redirected to patient index search

feature 'Signing in' do
  scenario 'Successful sign in with admin' do
    FactoryGirl.create(:admin)

    visit '/'

    fill_in 'Email', with: 'admin@admin.com'
    fill_in 'Password', with: 'password'
    click_on('Log in')

    expect(page).to have_current_path('/admin/dashboard')
    expect(page).to have_content('admin@admin.com')
    expect(page).to have_content('Dashboard')
    expect(page).to have_content('Signed in successfully.')
  end

  scenario 'Successful sign in with staff' do
    FactoryGirl.create(:staff)

    visit '/'

    fill_in 'Email', with: 'staff@staff.com'
    fill_in 'Password', with: 'password'
    click_on('Log in')

    expect(page).to have_current_path('/patients')
    expect(page).to have_content('Search Patients')
  end

  scenario 'Unsuccessful sign in routes back to homepage' do
    FactoryGirl.create(:admin)

    visit '/'

    fill_in 'Email', with: 'admin@admin.com'
    fill_in 'Password', with: 'bad_password'
    click_on('Log in')

    expect(page).to have_current_path('/')
    expect(page).to have_content('Invalid Email or password.')
    expect(page).to have_content('Log In')
  end

  scenario 'Unsuccessful sign in 4 times warns of locked account' do
    FactoryGirl.create(:admin)

    visit '/'

    4.times do
      fill_in 'Email', with: 'admin@admin.com'
      fill_in 'Password', with: 'bad_password'
      click_on('Log in')
    end
    expect(page).to have_current_path('/users/sign_in')
    expect(page).to have_content(
      'You have one more attempt before your account is locked.'
    )
    expect(page).to have_content('Log In')
  end
  scenario 'Unsuccessful sign in 5 times locks account' do
    FactoryGirl.create(:admin)

    visit '/'

    5.times do
      fill_in 'Email', with: 'admin@admin.com'
      fill_in 'Password', with: 'bad_password'
      click_on('Log in')
    end
    expect(page).to have_current_path('/users/sign_in')
    expect(page).to have_content('Your account is locked.')

    fill_in 'Email', with: 'admin@admin.com'
    fill_in 'Password', with: 'bad_password'
    click_on('Log in')

    expect(page).to have_current_path('/users/sign_in')
    expect(page).to have_content('Your account is locked.')
    expect(page).to have_content('Log In')
  end
end

# Ensure sign in admin goes to admin homepage
# Ensure sign in staff goes to patients page
# Ensure signout goes to home page
#
# Ensure all pages are unavailable to non signed in users
# Ensure all admin pages are unavailable to staff
# Ensure all patients pages are available to admin
