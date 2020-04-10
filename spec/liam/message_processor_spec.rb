# frozen_string_literal: true

require 'spec_helper'
require 'liam/test_producer'

RSpec.describe Liam::MessageProcessor do
  let(:config_path) { File.expand_path('spec/support/liam_config.yml') }
  let(:string_value) { 'liam_TestProducer' }
  let(:sent_message) do
    { books: [{ id: 1, isbn10: '9561111853' }, { id: 2, isbn10: '9562623246' }] }
  end
  let(:message) do
    Aws::SQS::Types::Message.new(
      message_id: '9e5172f1-b3dc-4b26-b7b9-54cbe80fe10',
      receipt_handle: 'XXXXXXX',
      md5_of_body: 'e3c6eb96e4a77aa181d654396eed8692',
      body: {
        'MessageId' => 'ae5f3c82-a0e1-47a1-b2e2-2aad30f1f955',
        'Type' => 'Notification',
        'Timestamp' => '2020-04-07T08:09:39.425213Z',
        'Message' => sent_message.to_json,
        'TopicArn' => 'arn:aws:sns:us-east-1:000000000000:liam_TestProducer',
        'Subject' => 'liam message',
        'MessageAttributes' => {
          'event_name' => {
            'Type' => 'String',
            'Value' => string_value
          }
        }
      }.to_json,
      attributes: {
        'SentTimestamp' => '1586249319798',
        'ApproximateReceiveCount' => '1',
        'ApproximateFirstReceiveTimestamp' => '1586249319798',
        'SenderId' => '127.0.0.1',
        'MessageDeduplicationId' => '',
        'MessageGroupId' => ''
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
