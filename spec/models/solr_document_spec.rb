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

  describe '#defense' do
    subject { document.defense }

    context 'with no defense date' do
      let(:document) { described_class.new }

      it { is_expected.to eq('None') }
    end

    context 'with defense date' do
      let(:document) { described_class.new(defended_at_dtsi: '2006-10-10T00:00:00Z') }

      it { is_expected.to eq('October 10, 2006') }
    end
  end

  describe '#defended_at' do
    subject { document.defended_at }

    context 'with no defense date' do
      let(:document) { described_class.new }

      it { is_expected.to be_nil }
    end

    context 'with defense date' do
      let(:document) { described_class.new(defended_at_dtsi: '2006-10-10T00:00:00Z') }

      it { is_expected.to eq('2006-10-10T00:00:00Z') }
    end
  end
end
