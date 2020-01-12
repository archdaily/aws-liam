# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Liam::Consumer do
  let(:config_path) { File.expand_path('spec/support/liam_config.yml') }
  let(:event) { 'liam_TestProducer' }
  let(:consumer) { described_class.new }
  let(:sqs_queue) { 'http://localhost:4576/queue/liam_gem' }
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
                data_type: 'String',
                Value: event
              }
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
        ),
        Aws::SQS::Types::Message.new(
          message_id: '77c972cf-fbaa-4d98-b0d9-f66196da3987',
          receipt_handle: '77c972cf-fbaa-4d98-b0d9-f66196da3986#f7307ca5-0580-4e52-b8e9-c8e0f7ec4326',
          md5_of_body: 'bd6e137230719036d2bd8008c1e11a3e',
          body: {
            MessageId: '7beeffda-2519-4ea7-8fe3-b52c629053a3',
            Type: 'Notification',
            Timestamp: '2020-01-07T11:32:13.189883Z',
            Message: {
              books: nil
            },
            TopicArn: 'arn:aws:sns:us-east-1:000000000000:liam_TestProducer',
            MessageAttributes: {
              event_name: {
                data_type: 'String',
                Value: event
              }
            }
          }.to_json,
          attributes: {
            SentTimestamp: '1578396733209',
            ApproximateReceiveCount: '1',
            ApproximateFirstReceiveTimestamp: '1578396733209',
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
  let(:poller) { Aws::SQS::QueuePoller.new(nil, client: Aws::SQS::Client.new) }

  before do
    stub_const('Liam::Common::CONFIG_FILE', config_path)
    allow(poller).to receive(:poll).and_yield(messages)
    allow(consumer).to receive(:poller).and_return(poller)
  end

  it 'initializes MessageProcessor passing each message received' do
    expect(Liam::MessageProcessor).to receive(:process).with(messages[0])
    expect(Liam::MessageProcessor).to receive(:process).with(messages[1])
    consumer.send(:execute)
  end
end
