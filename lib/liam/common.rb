# frozen_string_literal: true

require 'yaml'

module Liam
  module Common
    UNSUPPORTED_MESSAGE_ERROR = 'Unsupported message argument'
    UNSUPPORTED_TOPIC_ERROR = 'Unsupported topic argument'

    def sns_client
      @sns_client ||= Aws::SNS::Client.new(client_options)
    end

    def sqs_client
      @sqs_client ||= Aws::SQS::Client.new(client_options)
    end

    def poller
      @poller ||= Aws::SQS::QueuePoller.new(sqs_queue, client: sqs_client)
    end

    def config
      "#{File.expand_path(__dir__)}/config/liam.yml"
    end

    def client_options
      {
        access_key_id: env_credentials['aws']['access_key_id'],
        endpoint: env_credentials['aws']['sns']['endpoint'],
        region: env_credentials['aws']['region'],
        secret_access_key: env_credentials['aws']['secret_access_key']
      }
    end

    def env_credentials
      credentials[ENV['RAILS_ENV']]
    end

    def credentials
      YAML.load_file(config)
    end
  end
end
