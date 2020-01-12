# frozen_string_literal: true

module Liam
  class NoTopicsInConfigFileError < StandardError
    def initialize
      super('No topics found in the Liam configuration file.')
    end
  end
end
