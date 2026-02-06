# frozen_string_literal: true

require 'rails_helper'
require 'faraday'
require 'etda_utilities'

RSpec.describe AutoRemediateWebhookService do
  let(:final_submission_file_id) { 12345 }
  let(:webhook_token) { 'secret-key' }
  let(:full_url) { 'https://workflow.example.test/webhooks/auto_remediate' }

  before do
    ENV['WORKFLOW_HOST'] = 'workflow.example.test'
    ENV["AUTO_REMEDIATE_WEBHOOK_PATH_#{current_partner.slug.upcase}"] = '/webhooks/auto_remediate'
    ENV["AUTO_REMEDIATE_WEBHOOK_TOKEN_#{current_partner.slug.upcase}"] = webhook_token

    stub_request(:post, /#{full_url}/)
      .with(headers: {
              'Content-Type' => 'application/json',
              'X-API-Key' => webhook_token
            },
            body: { final_submission_file_id: final_submission_file_id }.to_json)
      .to_return(response_body)
  end

  after do
    ENV.delete('WORKFLOW_HOST')
    ENV.delete("AUTO_REMEDIATE_WEBHOOK_PATH_#{current_partner.slug.upcase}")
    ENV.delete("AUTO_REMEDIATE_WEBHOOK_TOKEN_#{current_partner.slug.upcase}")
  end

  describe '#notify' do
    let(:response_body) { { status: 200, body: 'ok' } }

    context 'when webhook path and token are set' do
      it 'posts JSON with the expected headers and returns the response' do
        resp = described_class.new(final_submission_file_id).notify
        expect(resp.status).to be(200)
        expect(resp.body).to be('ok')
      end
    end

    context 'when webhook token is missing' do
      it 'raises KeyError' do
        ENV.delete("AUTO_REMEDIATE_WEBHOOK_TOKEN_#{current_partner.slug.upcase}")

        expect {
          described_class.new(final_submission_file_id).notify
        }.to raise_error(KeyError)
      end
    end

    context 'when webhook path is missing' do
      it 'raises KeyError' do
        ENV.delete("AUTO_REMEDIATE_WEBHOOK_PATH_#{current_partner.slug.upcase}")
        expect {
          described_class.new(final_submission_file_id).notify
        }.to raise_error(KeyError)
      end
    end

    context 'when network errors occur but succeeds before retry limit' do
      before do
        stub_request(:post, /#{full_url}/)
          .with(headers: {
                  'Content-Type' => 'application/json',
                  'X-API-Key' => webhook_token
                },
                body: { final_submission_file_id: final_submission_file_id }.to_json)
          .to_timeout.then
          .to_raise(Faraday::ConnectionFailed.new('connection failed')).then
          .to_raise(Faraday::ConnectionFailed.new('connection failed')).then
          .to_return(status: 200, body: 'ok')
      end

      it 'retries the request and eventually succeeds' do
        resp = described_class.new(final_submission_file_id).notify
        expect(resp.status).to be(200)
        expect(resp.body).to be('ok')
      end
    end

    context 'when network errors occur but exceeds retry limit' do
      before do
        stub_request(:post, /#{full_url}/)
          .with(headers: {
                  'Content-Type' => 'application/json',
                  'X-API-Key' => webhook_token
                },
                body: { final_submission_file_id: final_submission_file_id }.to_json)
          .to_timeout.then
          .to_raise(Faraday::ConnectionFailed.new('connection failed')).then
          .to_timeout.then
          .to_raise(Faraday::SSLError.new('SSL error')).then
          .to_timeout
      end

      it 'raises the last encountered error after exhausting retries' do
        expect {
          described_class.new(final_submission_file_id).notify
        }.to raise_error(Faraday::ConnectionFailed)
      end
    end
  end
end
