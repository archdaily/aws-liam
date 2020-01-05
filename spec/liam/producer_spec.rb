# frozen_string_literal: true

require 'spec_helper'
require 'pry'
require 'active_support/core_ext/object'
require 'active_support/json'

RSpec.describe Liam::Producer do
  let(:config_path) { File.expand_path('spec/support/liam_config.yml') }
  let(:message) { { books: [{ id: 1, isbn10: '9561111853' }, { id: 2, isbn10: '9562623246' }] } }
  let(:topic) { 'liam_TestProducer' }

  before do
    allow(described_class).to receive(:new).and_return(producer)
    allow(producer).to receive(:config).and_return(config_path)
  end

  describe 'topic argument validation' do
    describe 'when invoked with an unsupported topic object' do
      context 'when invoked with topic nil' do
        let(:producer) { described_class.send(:new, message: message, topic: nil) }

        it { expect { producer.execute }.to raise_error(Liam::Common::UNSUPPORTED_TOPIC_ERROR) }
      end

      context 'when invoked with empty string topic' do
        let(:producer) { described_class.send(:new, message: message, topic: '') }

        it { expect { producer.execute }.to raise_error(Liam::Common::UNSUPPORTED_TOPIC_ERROR) }
      end
    end
  end

  describe 'message argument validation' do
    describe 'when invoked with a message other than a Symbol' do
      context 'when invoked with message nil' do
        let(:producer) { described_class.send(:new, message: nil, topic: topic) }

        it { expect { producer.execute }.to raise_error(Liam::Common::UNSUPPORTED_MESSAGE_ERROR) }
      end

      context 'when invoked with empty string message' do
        let(:producer) { described_class.send(:new, message: '', topic: topic) }

        it { expect { producer.execute }.to raise_error(Liam::Common::UNSUPPORTED_MESSAGE_ERROR) }
      end
    end
  end

  describe 'successful implementation' do
    let(:producer) { described_class.send(:new, message: message, topic: topic) }
    let(:json_message) { message.to_json }
    let(:publish_message) { producer.execute }
    let(:http_request) { publish_message.instance_variable_get(:@http_request) }
    let(:publish_param_list) { http_request.body.param_list }
    let(:params) { publish_param_list.instance_variable_get(:@params) }
    let(:published_message) { params['Message'].value }
    let(:publish_topic_arn) { params['TopicArn'].value }
    let(:publish_action) { params['Action'].value }
    let(:message_query) { { 'Message': published_message }.to_query }

    it 'successfully publishes a message with credentials from config. file' do
      expect(publish_message).to be_successful
      expect(published_message).to eq(message.to_json)
      expect(publish_action).to eq('Publish')
      expect(publish_topic_arn).to eq('arn:aws:sns:us-east-1:000000000000:liam_TestProducer')
      expect(WebMock).to(
        have_requested(:post, 'http://localhost:4575/').with(body: /#{message_query}/)
      )
    end
  end
end
