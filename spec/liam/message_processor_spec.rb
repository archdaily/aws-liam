# frozen_string_literal: true

require 'spec_helper'
require 'liam/test_producer'

RSpec.describe Liam::MessageProcessor do
  let(:config_path) { File.expand_path('spec/support/liam_config.yml') }
  let(:string_value) { 'liam_TestProducer' }
  let(:message) do
    Aws::SQS::Types::Message.new(
      message_id: '9e5172f1-b3dc-4b26-b7b9-54cbe80fe10',
      receipt_handle: 'XXXXXXX',
      md5_of_body: 'e3c6eb96e4a77aa181d654396eed8692',
      body: { books: [{ id: 1, isbn10: '9561111853' }, { id: 2, isbn10: '9562623246' } ]}.to_json,
      attributes: {
        'SenderId'=>'AIDAIT2UOQQY3AUEKVGXU',
        'ApproximateFirstReceiveTimestamp'=>'1582032411670',
        'ApproximateReceiveCount'=>'1',
        'SentTimestamp'=>'1582032411669'
      },
      message_attributes: {
        'event_name' => Aws::SQS::Types::MessageAttributeValue.new(
          string_value: string_value,
          binary_value: nil,
          string_list_values: [],
          binary_list_values: [],
          data_type: 'String'
        )
      }
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
      let(:string_value) { nil }

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
