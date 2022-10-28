# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GoogleScholarMetadataComponent, type: :component do
  include Rails.application.routes.url_helpers

  subject(:component) { described_class.new(document: doc) }

  let(:doc) { SolrDocument.new(fake_solr_doc) }

  before do
    Blacklight.default_index.connection.add(doc)
    Blacklight.default_index.connection.commit
  end

  context 'with a final submission file pdf' do
    let(:html) { render_inline(component) }
    let(:fake_solr_doc) { FakeSolrDocument.new(access_level: 'open_access').doc }

    it 'renders all the meta tags' do
      expect(html.search('meta[@name="citation_title"]')
        .first['content']).to eq(doc[:title_tesi])
      expect(html.search('meta[@name="citation_author"]')
        .first['content']).to eq(doc[:author_name_tesi])
      expect(html.search('meta[@name="citation_publication_date"]')
        .first['content']).to eq(doc[:released_metadata_at_dtsi].to_date.year.to_s)
      expect(html.search('meta[@name="citation_pdf_url"]').first['content']).to eq(
        final_submission_file_url(doc.final_submissions.first.first, host: 'http://test.host')
      )
    end
  end

  context 'when the final submission file is not a pdf' do
    let(:html) { render_inline(component) }
    let(:fake_solr_doc) { FakeSolrDocument.new(access_level: 'open_access', file_names: ['word_doc.docx']).doc }

    it 'renders all the meta tags' do
      expect(html.search('meta[@name="citation_title"]')
        .first['content']).to eq(doc[:title_tesi])
      expect(html.search('meta[@name="citation_author"]')
        .first['content']).to eq(doc[:author_name_tesi])
      expect(html.search('meta[@name="citation_publication_date"]')
        .first['content']).to eq(doc[:released_metadata_at_dtsi].to_date.year.to_s)
      expect(html.search('meta[@name="citation_pdf_url"]')).to be_empty
    end
  end

  context 'when the final submission is not open_access' do
    let(:html) { render_inline(component) }
    let(:fake_solr_doc) { FakeSolrDocument.new(access_level: 'restricted_to_institution').doc }

    it 'renders all the meta tags' do
      expect(html.search('meta[@name="citation_title"]')
        .first['content']).to eq(doc[:title_tesi])
      expect(html.search('meta[@name="citation_author"]')
        .first['content']).to eq(doc[:author_name_tesi])
      expect(html.search('meta[@name="citation_publication_date"]')
        .first['content']).to eq(doc[:released_metadata_at_dtsi].to_date.year.to_s)
      expect(html.search('meta[@name="citation_pdf_url"]')).to be_empty
    end
  end
end
