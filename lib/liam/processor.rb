# frozen_string_literal: true

module Liam
  module Processor
    def initialize(message)
      @message = message
    end

    private

    attr_reader :message
  end
end
