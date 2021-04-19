# frozen_string_literal: true

module Liam
  class NoConfigForEnvError < StandardError
    def initialize
      super('No configuration was found for the environment in the Liam configuration file.')
    end
  end
end
