# frozen_string_literal: true

ENV['RAILS_ENV'] = 'test'

require 'liam'
require 'webmock/rspec'

RSpec.configure do |config|
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end

WebMock.allow_net_connect!(net_http_connect_on_start: true)
