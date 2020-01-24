# frozen_string_literal: true

module Liam
  class UnexpectedMessageError < StandardError
    def initialize(message)
      super("Expected #{message.class} to be an instance of Aws::SQS::Types::Message.")
    end
  end
end
