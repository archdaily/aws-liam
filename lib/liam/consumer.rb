require 'json'
require 'aws-sdk-sqs'
require 'liam/common'

module Liam
  class Consumer
    include Liam::Common

    def self.message(*args)
      new(*args).send(:execute)
    end

    # TODO: delete message optional
    def execute
      poller.poll(skip_delete: true, max_number_of_messages: 10) do |messages|
        messages.each do |message|
          process_message
        end
      end
    raise Aws::SQS::Errors::ServiceError => e
      puts "Fatal Error... #{e}"
    end

    def sqs_queue
      @sqs_queue ||= liam_yaml['aws']['sqs_queue']
    end

    def process_message
      @message = JSON.parse(message.body)['Message']
      Object.const_get(topic_class).send(:new, message).send(:process)
    rescue LoadError, RuntimeError, NameError
      'Error processing message from SQS'
    end

    def topic_class
      event_name = message['MessageAttributes']['event_name']['Value']
      event_name.split('_').map(&:capitalize).join('::')
    end

    def delete_message
      client.delete_message(queue_url: SQS_QUEUE, receipt_handle: message.receipt_handle)
    end

    private

    attr_accessor :message
  end
end
