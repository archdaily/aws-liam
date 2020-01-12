# frozen_string_literal: true

require 'spec_helper'
require 'liam/test_producer'

RSpec.describe Liam::MessageProcessor do
  let(:config_path) { File.expand_path('spec/support/liam_config.yml') }
  let(:event) { 'liam_TestProducer' }
  let(:value_message_attribute) { { Value: event } }
  let(:message) do
    Aws::SQS::Types::Message.new(
      message_id: '77c972cf-fbaa-4d98-b0d9-f66196da3986',
      receipt_handle: '77c972cf-fbaa-4d98-b0d9-f66196da3986#f7307ca5-0580-4e52-b8e9-c8e0f7ec4325',
      md5_of_body: 'bd6e137230719036d2bd8008c1e11a3d',
      body: {
        MessageId: '7beeffda-2519-4ea7-8fe3-b52c629053a2',
        Type: 'Notification',
        Timestamp: '2020-01-07T11:32:13.189882Z',
        Message: {
          books: [
            { id: 1, isbn10: '9561111853' },
            { id: 2, isbn10: '9562623246' }
          ]
        },
        TopicArn: 'arn:aws:sns:us-east-1:000000000000:liam_TestProducer',
        MessageAttributes: {
          event_name: {
            data_type: 'String'
          }.merge(value_message_attribute)
        }
      }.to_json,
      attributes: {
        SentTimestamp: '1578396733208',
        ApproximateReceiveCount: '1',
        ApproximateFirstReceiveTimestamp: '1578396733208',
        SenderId: '127.0.0.1',
        MessageDeduplicationId: '',
        MessageGroupId: ''
      },
      md5_of_message_attributes: nil,
      message_attributes: {}
    )
  end

  describe 'failure cases' do
    context 'when the class expected to process the message has not been initialized' do
      before do
        Liam.send(:remove_const, :TestProducer)
      end

      after(:all) do
        module Liam
          class TestProducer
            def initialize(message)
              @message = message
            end

            def process; end
          end
        end
      end

      it do
        expect { described_class.process(message) }.to(
          raise_error(
            Liam::UninitializedMessageProcessorError,
            <<~MSG.gsub(/\n/, '')
              Expected file Liam::TestProducer defined in app/services/liam to process 
              the message, but it has not been initialized.
            MSG
          )
        )
      end
    end

    context 'when the message received does not have a expected Value key' do
      let(:value_message_attribute) { { string_value: event } }

      it 'raises a custom MessageWithoutValueAttributeError' do
        expect { described_class.process(message) }.to(
          raise_error(
            Liam::MessageWithoutValueAttributeError,
            <<~MSG.gsub(/\n/, '')
              Expected to get a message attribute value to initialize the class to process 
              this message, but the value received is invalid.
            MSG
          )
        )
      end
    end

    context 'when initialized without an Aws::SQS::Types::Message object' do
      let(:message) { nil }

      it do
        expect { described_class.process(message) }.to(
          raise_error(
            Liam::UnexpectedMessageError,
            "Expected #{message.class} to be an instance of Aws::SQS::Types::Message."
          )
        )
      end
    end
  end

  describe 'success cases' do
    it 'invokes the process method in the class expected to process the message' do
      mock = double(Liam::TestProducer)
      expect(Liam::TestProducer).to receive(:new).and_return(mock)
      expect(mock).to receive(:process)
      described_class.process(message)
    end
  end
end
