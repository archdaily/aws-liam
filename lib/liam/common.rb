# frozen_string_literal: true

require 'yaml'

module Liam
  module Common
    CONFIG_FILE = 'config/liam.yml'

    def client_options
      {
        access_key_id: env_credentials['aws']['access_key_id'],
        endpoint: env_credentials['aws']['sns']['endpoint'],
        region: env_credentials['aws']['region'],
        secret_access_key: env_credentials['aws']['secret_access_key']
      }
    end

    def env_credentials
      @env_credentials ||= credentials[ENV['RAILS_ENV']]
    end

    # TODO: This might fail depending on how you're using the gem.
    #       Add dummy Rails app to test integration
    def credentials
      YAML.load_file(CONFIG_FILE)
    end
  end
end
