module Liam
  module Common
    def sqs_client
      @sqs_client ||= Aws::SQS::Client.new(client_options)
    end

    def sns_client
      @sns_client ||= Aws::SNS::Client.new(client_options)
    end

    def poller
      @poller ||= Aws::SQS::QueuePoller.new(sqs_queue, client: sqs_client)
    end

    def client_options
      {
        region: credentials['region'],
        access_key_id: credentials['access_key_id'],
        secret_access_key: credentials['secret_access_key']
      }
    end

    def credentials
      @credentials ||= liam_yaml['aws']
    end

    def liam_yaml
      @liam_yaml ||= begin
        yaml = YAML.load_file("config/liam.yml")
        yaml[ENV['RACK_ENV']]
      end
    end
  end
end
