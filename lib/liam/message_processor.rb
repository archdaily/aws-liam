# frozen_string_literal: true

require 'json'
require 'forwardable'

module Liam
  class MessageProcessor
    extend Forwardable

    def initialize(message)
      @message = message
    end

    def self.process(message)
      raise UnexpectedMessageError, message unless message.is_a?(Aws::SQS::Types::Message)
      puts "[aws-liam] Processing #{message}"

      new(message).send(:process)
    end

    private

    attr_reader :message

    private(*def_delegator(:message, :body))
    private(*def_delegator(:processor, :process))

    def parsed_message
      JSON.parse(body)
    end

    def processor
      Object.const_get(message_topic_name).new(parsed_message)
    rescue NameError => e
      raise UninitializedMessageProcessorError, e
    end

    def message_topic_name
      message_attribute_value.sub('_', '::').gsub(/(?<=^)(.*)(?=::)/, &:capitalize)
    end

    def message_attribute_value
      raise MessageWithoutValueAttributeError if value.nil? || value.empty?

      value
    end

    def value
      @value ||= begin
                   return if parsed_message.nil? || parsed_message.empty?

                   message.message_attributes['event_name']&.string_value ||
                     parsed_message.dig('MessageAttributes', 'event_name', 'Value')
                 end
    end
  end
end
