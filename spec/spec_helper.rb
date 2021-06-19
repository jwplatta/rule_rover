require 'bundler/setup'
Bundler.setup

require 'my_ken'

RSpec.configure do |config|
  config.example_status_persistence_file_path = '.rspec_status'
end