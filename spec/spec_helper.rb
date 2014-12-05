require 'spec_assist'

RSpec.configure do |config|
  config.extend Assist
  config.order = :random
end
