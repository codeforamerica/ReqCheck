source 'https://rubygems.org'
ruby '2.3.1'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.7.1'
gem 'rails_12factor'
gem 'pg'
gem 'uglifier', '>= 1.3.0'
gem 'therubyracer'

gem 'foundation-rails', '~> 6.2.0'
gem 'sass-rails'
gem 'autoprefixer-rails'

gem 'jquery-rails'

# webserver, production
gem 'puma'

# Americanization of dates
gem 'american_date'

# paperclip to upload files
# gem 'paperclip', '~> 5.0.0'

gem 'devise'
gem 'activeadmin', git: 'https://github.com/activeadmin/activeadmin'

gem 'sitemap_generator'

# HIPAA?
# gem 'newrelic_rpm'

# HIPAA?
# gem 'bugsnag'

group :development, :test do
  gem 'factory_girl_rails'
  gem 'byebug'
  gem 'rails-erd'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'brakeman', require: false
  gem 'dawnscanner', require: false
end

group :test do
  gem 'rspec'
  gem 'rspec-rails'
  gem 'faker'
  gem 'database_cleaner'
  gem 'capybara'
  gem 'capybara-webkit'
  gem 'timecop'
  gem 'codeclimate-test-reporter', require: false
  gem 'shoulda-matchers', '~> 3.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
