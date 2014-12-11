require 'spec_assist'
require 'webmock/rspec'

RSpec.configure do |config|
  config.extend Assist
  config.order = :random
end
