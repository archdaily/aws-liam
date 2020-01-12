# frozen_string_literal: true

ENV['RAILS_ENV'] = 'test'

require 'liam'
require 'webmock/rspec'
require 'pry'

RSpec.configure do |config|
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
    mocks.verify_doubled_constant_names = true
  end
end

WebMock.allow_net_connect!(net_http_connect_on_start: true)
