require 'bundler/setup'

Bundler.setup

require 'active_record'
require 'performify'

ActiveRecord::Base.establish_connection adapter: 'sqlite3', database: ':memory:'

RSpec.configure do |config|
  config.mock_with :rspec do |mocks|
    mocks.verify_doubled_constant_names = true
  end
end
