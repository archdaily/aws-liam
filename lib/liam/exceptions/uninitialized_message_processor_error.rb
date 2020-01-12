# frozen_string_literal: true

module Liam
  class UninitializedMessageProcessorError < StandardError
    def initialize(error)
      @error = error
      super(
        <<~MSG.gsub(/\n/, '')
          Expected file #{class_name} 
          defined in app/services/liam to process the message, 
          but it has not been initialized.
        MSG
      )
    end

    private

    attr_reader :error

    def class_name
      error.to_s[/[\w+::+\w+]+(?=\z)/]
    end
  end
end
