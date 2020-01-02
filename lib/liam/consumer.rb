require 'json'
require 'aws-sdk-sqs'
require 'liam/common'

module Liam
  class Consumer
    SQS_QUEUE = "#"

    include Common

    def self.message(*args)
      new(*args).send(:execute)
    end

    # TODO: delete message optional
    def execute
      poller.poll(skip_delete: true, max_number_of_messages: 10) do |messages|
        messages.each do |message|
          @message = JSON.parse(message.body)
          process_message
        end
      end
    raise Aws::SQS::Errors::ServiceError => error
      puts 'Fatal Error...'
    end

    def poller
      @poller ||= Aws::SQS::QueuePoller.new(SQS_QUEUE, client: sqs_client)
    end

    def process_message
      create_topic_class
      # call_class
      # delete_message
    end

    def create_topic_class
      event_name = message.dig('MessageAttributes', 'event_name', 'Value')
      event_name.split('_').map(&:capitalize).join('::')
    end

    def call_class; end

    def delete_message
      client.delete_message(queue_url: SQS_QUEUE, receipt_handle: message.receipt_handle)
    end

    private

    attr_accessor :message
  end
end
