# frozen_string_literal: true

require 'json'
require 'aws-sdk-sqs'
require 'liam/common'

module Liam
  class UnableToInferMessageProcessorError < StandardError; end

  class Consumer
    include Liam::Common

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
        messages.each { |message| process_message(message) }
      end
    rescue Aws::SQS::Errors::ServiceError => e
      puts "ServiceError #{e}"
    end

    def process_message(message)
      @message = JSON.parse(message.body)
      Object.const_get(extract_topic_name).new(@message['Message']).process
    end

    def extract_topic_name
      event_name = @message['MessageAttributes']['event_name']['string_value']
      raise UnableToInferMessageProcessorError unless event_name

      event_name.split('_').map(&:camelize).join('::')
    end

    def poller_options
      { max_number_of_messages: options['max_message'] || options[:max_message] || 10 }
    end
  end
end
