# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Liam::Producer do
  let(:config_path) { File.expand_path('spec/support/liam_config.yml') }
  let(:message) do
    {
      books: [
        { id: 1, isbn10: '9561111853' },
        { id: 2, isbn10: '9562623246' }
      ]
    }
  end
  let(:topic) { 'liam_TestProducer' }
  let(:arn) { 'arn:aws:sns:us-east-1:000000000000:liam_TestProducer' }
  let(:sns_url) { 'http://localhost:4566/' }

  before do
    stub_const('Liam::Common::CONFIG_FILE', config_path)
  end

  describe 'topic argument validation' do
    describe 'when invoked with an unsupported topic object' do
      context 'when invoked with topic nil' do
        it do
          expect(described_class.message(message: message, topic: nil)).to(
            eq(described_class::UNSUPPORTED_TOPIC_ERROR)
          )
        end
      end

      context 'when invoked with empty string topic' do
        it do
          expect(described_class.message(message: message, topic: '')).to(
            eq(described_class::UNSUPPORTED_TOPIC_ERROR)
          )
        end
      end
    end
  end

  describe 'message argument validation' do
    describe 'when invoked with a message other than a Symbol' do
      context 'when invoked with message nil' do
        it do
          expect(described_class.message(message: nil, topic: topic)).to(
            eq(described_class::UNSUPPORTED_MESSAGE_ERROR)
          )
        end
      end

      context 'when invoked with empty string message' do
        it do
          expect(described_class.message(message: '', topic: topic)).to(
            eq(described_class::UNSUPPORTED_MESSAGE_ERROR)
          )
        end
      end
    end
  end

  describe '#execute' do
    subject { described_class.send(:new, message: message, topic: topic) }

    context 'when environment does not have configuration' do
      before { allow(subject).to receive(:env_credentials) }

      it 'raises' do
        expect { subject.send(:execute) }.to raise_error(Liam::NoConfigForEnvError)
      end
    end

    context 'when unable to get the topics key from the configuration file' do
      before { allow(subject).to receive(:topics) }

      it 'raises' do
        expect { subject.send(:execute) }.to raise_error(Liam::NoTopicsInConfigFileError)
      end
    end

    context 'when environment is skipped' do
      before { allow(ENV).to receive(:[]).with("RAILS_ENV").and_return("staging") }

      it { expect(subject.send(:execute)).to eq described_class::SKIPPED_MESSAGE }
    end
  end


  describe 'successful implementation' do
    let(:producer) { described_class.send(:new, message: message, topic: topic) }
    let(:json_message) { message.to_json }
    let(:publish_message) { producer.send(:execute) }
    let(:http_request) { publish_message.instance_variable_get(:@http_request) }
    let(:publish_param_list) { http_request.body.param_list }
    let(:params) { publish_param_list.instance_variable_get(:@params) }
    let(:published_message) { params['Message'].value }
    let(:publish_topic_arn) { params['TopicArn'].value }
    let(:publish_action) { params['Action'].value }
    let(:message_query) { URI.encode_www_form('Message': published_message) }

    it 'publishes a message with credentials from config. file' do
      expect(publish_message).to be_successful
      expect(published_message).to eq(message.to_json)
      expect(publish_action).to eq('Publish')
      expect(publish_topic_arn).to eq(arn)
      expect(WebMock).to have_requested(:post, sns_url).with(body: /#{message_query}/)
    end
  end
end
