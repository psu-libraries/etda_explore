# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HealthChecks::SolrCheck do
  describe '#check' do
    before(:all) do
      WebMock.disable_net_connect!
    end

    after(:all) do
      WebMock.enable_net_connect!
    end

    context 'when we can connect to solr' do
      before do
        stub_request(:get, /admin\/ping/)
          .to_return(status: 200, body: {
            responseHeader: {
              zkConnected: true
            },
            status: 'OK'
          }.to_json)
      end

      it 'returns no failure' do
        hc = described_class.new
        hc.check
        expect(hc.failure_occurred).to be_nil
      end
    end

    context 'when zk is not connected' do
      before do
        stub_request(:get, /admin\/ping/)
          .to_return(status: 200, body: {
            responseHeader: {
              zkConnected: false
            },
            status: 'OK'
          }.to_json)
      end

      it 'returns a failure' do
        hc = described_class.new
        hc.check
        expect(hc.failure_occurred).to be true
      end
    end
  end
end
