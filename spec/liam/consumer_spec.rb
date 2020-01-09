# frozen_string_literal: true

require 'spec_helper'
require 'pry'
require 'active_support/core_ext/object'
require 'active_support/json'
require 'liam/test_producer'

RSpec.describe Liam::Consumer do
  let(:config_path) { File.expand_path('spec/support/liam_config.yml') }
  let(:event) { 'liam_TestProducer' }
  let(:consumer) { described_class.new }
  let(:string_value_message_attribute) do
    { string_value: event }
  end
  let(:message) do
    {
      books: [
        { id: 1, isbn10: '9561111853' },
        { id: 2, isbn10: '9562623246' }
      ]
    }
  end
  let(:messages) do
    Aws::Xml::DefaultList.new(
      [
        Aws::SQS::Types::Message.new(
          message_id: '77c972cf-fbaa-4d98-b0d9-f66196da3986',
          receipt_handle: '77c972cf-fbaa-4d98-b0d9-f66196da3986#f7307ca5-0580-4e52-b8e9-c8e0f7ec4325',
          md5_of_body: 'bd6e137230719036d2bd8008c1e11a3d',
          body: {
            MessageId: '7beeffda-2519-4ea7-8fe3-b52c629053a2',
            Type: 'Notification',
            Timestamp: '2020-01-07T11:32:13.189882Z',
            Message: message,
            TopicArn: 'arn:aws:sns:us-east-1:000000000000:liam_TestProducer',
            MessageAttributes: {
              event_name: {
                data_type: 'String'
              }.merge(string_value_message_attribute)
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
      ]
    )
  end

  before do
    allow_any_instance_of(Liam::Consumer).to receive(:config).and_return(config_path)
  end

  describe 'failure cases' do
    context 'when the class expected to process the message is not defined' do
      before do
        Liam.send(:remove_const, :TestProducer)
        allow(consumer.poller).to receive(:poll).and_yield(messages)
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
        expect { consumer.send(:execute) }.to(
          raise_error(NameError, 'uninitialized constant Liam::TestProducer')
        )
      end
    end

    context 'when the message received does not have a expected string_value key' do
      let(:string_value_message_attribute) do
        { Value: event }
      end

      before { allow(consumer.poller).to receive(:poll).and_yield(messages) }

      it do
        expect { consumer.send(:execute) }.to raise_error(Liam::UnableToInferMessageProcessorError)
      end
    end
  end

  describe 'successful implementation' do
    before do
      allow(consumer.poller).to receive(:poll).and_yield(messages)
    end

    it 'invokes the process method in the class expected to process the message' do
      mock = instance_double(Liam::TestProducer)
      expect(Liam::TestProducer).to receive(:new).and_return(mock)
      expect(mock).to receive(:process)
      consumer.send(:execute)
    end
  end
end
