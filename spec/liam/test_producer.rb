# frozen_string_literal: true

module Liam
  class TestProducer
    def initialize(message)
      @message = message
    end

    def process; end
  end
end
