require 'bundler/setup'
Bundler.setup

require 'my_ken'
require 'pry'

RSpec.configure do |config|
  config.example_status_persistence_file_path = '.rspec_status'
  config.filter_run_when_matching :focus
end