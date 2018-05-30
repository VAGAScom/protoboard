require "bundler/setup"
require "simplecov"

SimpleCov.start do
  add_filter "/spec/"
end

require "protoboard"
require_relative "./helpers/circuit_breaker_helpers"
require_relative "./support/custom_matchers"


RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.include CircuitBreakerHelpers
end
