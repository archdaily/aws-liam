# frozen_string_literal: true

require 'aws-sdk-sns'
require 'forwardable'

module Liam
  class Producer
    DEFAULT_SUBJECT = 'liam message'
    UNSUPPORTED_MESSAGE_ERROR = 'Unsupported message argument'
    UNSUPPORTED_TOPIC_ERROR = 'Unsupported topic argument'
    private_constant :DEFAULT_SUBJECT

    include Common

    extend Forwardable

    def initialize(message:, options: {}, topic:)
      @message = message
      @options = options
      @topic = topic
    end

    def self.message(*args)
      new(*args).send(:execute)
    end

    private

    private_class_method :new

    attr_reader :topic, :message, :options

    def execute
      return UNSUPPORTED_TOPIC_ERROR unless supported_topic?
      return UNSUPPORTED_MESSAGE_ERROR unless message.is_a?(Hash)

      puts "INFO -- [aws-liam]: ** Publishing message: #{message} ** --"
      Aws::SNS::Client.new(client_options).publish(
        topic_arn: topic_arn,
        message: message.to_json,
        subject: options['subject'] || options[:subject] || DEFAULT_SUBJECT,
        message_attributes: message_attributes
      )
    end

    def supported_topic?
      (topic.is_a?(String) || topic.is_a?(Symbol)) && !topic.empty?
    end

    def message_attributes
      { event_name: { string_value: topic, data_type: 'String' } }
    end

    def topic_arn
      raise NoTopicsInConfigFileError unless topics

      topics[topic]
    end

    def topics
      return @topics if defined?(@topics)

      @topics = env_credentials['events']
    end
  end
end
