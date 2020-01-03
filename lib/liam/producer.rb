require 'json'
require 'aws-sdk-sns'
require 'liam/common'
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

    def topic_arn
      @topic_arn ||= liam_yaml['topics'][topic]
    end

    def execute
      return unless topic
      return unless message
      return unless validate_message?
      send_message
    end

    def send_message
      sns_client.publish(
        topic_arn: topic_arn,
        message: message,
        subject: subject,
        message_attributes: message_attributes
      )
    end

    def message_attributes
      {
        event_name: {
          string_value: topic,
          data_type: 'String'
        }
      }
    end

    def subject
      return 'liam message' unless options['subject']
      options['subject']
    end

    def validate_message?
      !!JSON.parse(message)
    rescue
      false
    end

    private

    attr_accessor :topic, :message, :options

    private_class_method :new
  end
end
