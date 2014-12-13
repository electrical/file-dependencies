require 'spec_assist'
require 'webmock/rspec'
require 'coveralls'

Coveralls.wear!

RSpec.configure do |config|
  config.extend Assist
  config.order = :random
end

