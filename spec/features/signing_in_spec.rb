# signing_in_spec.rb

feature 'Signing in' do
  scenario 'Successful sign in with admin' do
    visit '/'
    within 'nav' do
      click_link 'Sign in'
    end
    fill_in 'Email', with: 'test@testing.com'
    fill_in 'Password', with: 'password'
    fill_in 'Password confirmation', with: 'password'
    click_button 'Sign in'
    expect(page).to have_xpath('/patients')
    expect(page).to have_content('Search Patients')
  end
end
