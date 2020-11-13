require "bundler/setup"
require "olympus-camera"
require 'pathname'

Dir[Pathname.new(__FILE__).parent.join('helpers').to_s + '/*.rb'].each { |f| require f }


RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.include DataLoadHelpers
end
