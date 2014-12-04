require 'spec_assist'

fixtures = File.expand_path('./spec/fixtures')

RSpec.configure do |config|
  config.extend Assist
  config.order = :random
end
