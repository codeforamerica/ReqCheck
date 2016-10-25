# The `.rspec` file also contains a few flags that are not defaults but that
# users commonly want.
require_relative './support/time_help'
# require 'capybara/rspec'

# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
  # Add the custom helpers
  config.include TimeHelp
end
