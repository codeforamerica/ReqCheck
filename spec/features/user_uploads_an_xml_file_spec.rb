# spec/features/user_creates_a_foobar_spec.rb
require 'rails_helper'

feature 'User uploads an xml file' do
  scenario 'they see the xml file upload page' do
    visit xml_importer_path

    # fill_in 'Name', with: 'My foobar'
    # click_button 'Create Foobar'

    # expect(page).to have_css '.foobar-name', 'My foobar'
  end
end
