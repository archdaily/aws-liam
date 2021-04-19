# frozen_string_literal: true

require 'yaml'

module Liam
  module Common
    CONFIG_FILE = File.expand_path('config/liam.yml')

    def client_options
      {
        access_key_id: env_credentials.dig('aws', 'access_key_id'),
        endpoint: env_credentials.dig('aws', 'sns', 'endpoint'),
        region: env_credentials.dig('aws', 'region'),
        secret_access_key: env_credentials.dig('aws', 'secret_access_key')
      }.compact
    end

    def env_credentials
      @env_credentials ||= credentials[ENV['RAILS_ENV']]
    end

    def credentials
      YAML.load_file(CONFIG_FILE)
    end
  end
end
