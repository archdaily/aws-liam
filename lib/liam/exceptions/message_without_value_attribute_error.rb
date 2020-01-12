# frozen_string_literal: true

module Liam
  class MessageWithoutValueAttributeError < StandardError
    def initialize
      super(
        <<~MSG.gsub(/\n/, '')
        Expected to get a message attribute value to initialize the class to process 
        this message, but the value received is invalid.
        MSG
      )
    end
  end
end
