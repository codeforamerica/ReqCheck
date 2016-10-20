# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)

# Prevent database truncation if the environment is production
if Rails.env.production?
  abort('The Rails environment is running in production mode!')
end

require 'spec_helper'
require 'rspec/rails'

# Add additional requires below this line. Rails is not loaded until this point!
require 'database_cleaner'
require 'capybara/rspec'

# Use webkit with Capybara
Capybara.javascript_driver = :webkit

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }
# To be able to use the module TimeHelp in factory girl (note also used in rspec)
FactoryGirl::SyntaxRunner.send(:include, TimeHelp)

# Checks for pending migration and applies them before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  config.include FactoryGirl::Syntax::Methods

  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!

  # Database Cleaner
  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end
  config.before(:each) do |example|
    DatabaseCleaner.strategy =
      example.metadata[:js] ? :truncation : :transaction
    DatabaseCleaner.start
  end
  config.after(:each) do
    DatabaseCleaner.clean
  end

  # For fake user login helpers
  config.include Devise::TestHelpers, type: :controller

  # For Login Helpers in Feature Specs
  config.include Warden::Test::Helpers
  config.after :each do
    Warden.test_reset!
  end
end

# Shoulda matchers setup
Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
