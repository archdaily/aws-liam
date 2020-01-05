# frozen_string_literal: true

require 'json'
require 'aws-sdk-sns'
require 'yaml'

module Liam
  class Producer
    include Liam::Common

    def initialize(topic:, message:, options: {})
      @topic   = topic
      @message = message
      @options = options
    end

    def self.message(*args)
      new(*args).send(:execute)
    end

    def execute
      raise UNSUPPORTED_TOPIC_ERROR unless supported_topic?
      raise UNSUPPORTED_MESSAGE_ERROR unless message.is_a?(Hash)

      send_message
    end

    def send_message
      sns_client.publish(
        topic_arn: env_credentials['topics'][topic],
        message: message.to_json,
        subject: subject,
        message_attributes: message_attributes
      )
    end

    def message_attributes
      { event_name: { string_value: topic, data_type: 'String' } }
    end

    def subject
      options['subject'] || 'liam message'
    end

    private

    attr_accessor :topic, :message, :options

    private_class_method :new

    def supported_topic?
      return false unless topic.is_a?(String) || topic.is_a?(Symbol)

      !topic.empty?
    end
  end
end
