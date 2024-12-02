# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'OAI', type: :feature do
  before do
    @doc = FakeSolrDocument.new(released_metadata_at_dtsi: DateTime.parse('1999-01-01').getutc)
    Blacklight.default_index.connection.add(@doc.doc)
    Blacklight.default_index.connection.commit
  end

  it 'returns the document when using lower granularity' do
    visit '/catalog/oai?verb=ListRecords&from=1999-01-01&until=2010-01-01&metadataPrefix=oai_dc'
    expect(page).to have_content @doc.doc[:title_ssi]
  end

  it 'returns the document when using zulu time' do
    visit '/catalog/oai?verb=ListRecords&from=1999-01-01T00:00:00Z&until=2010-04-07T12:00:00Z&metadataPrefix=oai_dc'
    expect(page).to have_content @doc.doc[:title_ssi]
  end

  it 'does not return the document when outside of the range' do
    visit '/catalog/oai?verb=ListRecords&from=2000-01-01T00:00:00Z&until=2010-04-07T12:00:00Z&metadataPrefix=oai_dc'
    expect(page).to have_no_content @doc.doc[:title_ssi]
  end
end
