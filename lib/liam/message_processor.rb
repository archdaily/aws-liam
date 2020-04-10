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
      Liam.logger.info 'Processing...'

      new(message).send(:process)
    end

    private

    attr_reader :message

    private(*def_delegator(:message, :body))
    private(*def_delegator(:message, :message_attributes))
    private(*def_delegator(:processor, :process))

    def parsed_body
      JSON.parse(body)
    end

    def parsed_message
      JSON.parse(parsed_body['Message'])
    end

    def processor
      Object.const_get(message_topic_name).new(parsed_message)
    rescue NameError => e
      raise UninitializedMessageProcessorError, e
    end

    def topic_arn
      return '' unless parsed_body.is_a?(Hash)

      parsed_body['TopicArn'] || ''
    end

    def message_topic_name
      topic_arn.split(':').last.sub('_', '::').gsub(/(?<=^)(.*)(?=::)/, &:capitalize)
    end
  end
end
