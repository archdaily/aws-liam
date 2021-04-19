# frozen_string_literal: true
Dir["lib/liam/exceptions/*.rb"].each {|file| load file }

module Liam
  autoload :Consumer, 'liam/consumer'
  autoload :Processor, 'liam/processor'
  autoload :Producer, 'liam/producer'
  autoload :VERSION, 'liam/version'

  class << self
    attr_writer :logger

    def logger
      @logger ||= Logger.new($stdout).tap { |log| log.progname = self.name }
    end
  end
end
