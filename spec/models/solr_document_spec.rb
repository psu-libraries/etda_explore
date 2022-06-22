# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SolrDocument do
  let(:solr_doc) { described_class.new(FakeSolrDocument.new.doc) }

  describe '#to_semantic_values' do
    it 'adds path to :identifier' do
      expect(solr_doc.to_semantic_values[:identifier])
        .to eq ["#{EtdaUtilities::Hosts.explore_url}/catalog/#{solr_doc['id']}"]
    end

    it 'converts date to zulu' do
      expect(solr_doc.to_semantic_values[:date])
        .to eq [Date.parse(solr_doc['final_submission_files_uploaded_at_dtsi']).strftime('%Y-%m-%dT%H:%M:%SZ')]
    end
  end
end
