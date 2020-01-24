# frozen_string_literal: true

require 'aws-sdk-sqs'
require 'liam/common'
require 'liam/message_processor'

module Liam
  class Consumer
    include Common

    def initialize(options: {})
      @options = options
    end

    def self.message(*args)
      new(*args).send(:execute)
    end

    private

    attr_reader :options

    def execute
      poller.poll(poller_options) do |messages|
        messages.each do |message|
          MessageProcessor.process(message)
        end
      end
    end

    def poller
      Aws::SQS::QueuePoller.new(sqs_queue, client: Aws::SQS::Client.new(client_options))
    end

    def sqs_queue
      env_credentials.dig('aws', 'sqs', 'queue')
    end

    def poller_options
      { max_number_of_messages: options['max_message'] || options[:max_message] || 10 }
    end
  end
end
