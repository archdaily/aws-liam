require 'json'
require 'aws-sdk-sqs'
require 'liam/common'

module Liam
  class Consumer
    include Liam::Common

    def initialize(options: {})
      @skip_delete = options['delete'] || false
      @max_message = options['max_message'] || 10
      @wait_time_seconds = options['wait_time'] || 20
    end

    def self.message(*args)
      new(*args).send(:execute)
    end

    def execute
      poller.poll(options) do |messages|
        messages.each { |message| process_message(message) }
      end
    rescue Aws::SQS::Errors::ServiceError => e
      puts "ServiceError #{e}"
    end

    def options
      {
        skip_delete: @skip_delete,
        max_number_of_messages:  @max_message,
        wait_time_seconds: @wait_time_seconds
      }
    end

    def sqs_queue
      @sqs_queue ||= liam_yaml['aws']['sqs_queue']
    end

    def process_message(message)
      @message = JSON.parse(message.body)
      Object.const_get(extract_topic_name).send(:new, @message['Message']).send(:process)
    rescue LoadError, RuntimeError, NameError
      'Error processing message from SQS'
    end

    def extract_topic_name
      event_name = @message['MessageAttributes']['event_name']['Value']
      event_name.split('_').map(&:camelize).join('::')
    end

    def call_class; end

    def delete_message
      client.delete_message(queue_url: sqs_queue, receipt_handle: message.receipt_handle)
    end
  end
end
