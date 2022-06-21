# frozen_string_literal: true

require 'rails_helper'

# Note: I could not get an actual component test to work for this.  There is too much
# going on under the hood.  A feature test on the show page should suffice, since the show
# and index page both use CustomDocumentComponent.
RSpec.describe 'CustomDocumentComponent', type: :feature do
  context 'when the document is open access' do
    let(:doc) { FakeSolrDocument.new }

    before do
      doc.doc['access_level_ss'] = 'open_access'
      Blacklight.default_index.connection.add(doc.doc)
      Blacklight.default_index.connection.commit
    end

    it 'shows open access thumbnail' do
      visit "/catalog/#{doc.doc[:id]}"
      expect(page).to have_css("img[src*='open_access_icon']")
      expect(page).to have_content('Open Access')
    end
  end

  context 'when the document is restricted_to_institution' do
    let(:doc) { FakeSolrDocument.new }

    before do
      doc.doc['access_level_ss'] = 'restricted_to_institution'
      Blacklight.default_index.connection.add(doc.doc)
      Blacklight.default_index.connection.commit
    end

    it 'shows restricted to institution thumbnail' do
      visit "/catalog/#{doc.doc[:id]}"
      expect(page).to have_css("img[src*='restricted_to_institution_icon']")
      expect(page).to have_content('Restricted (Penn State Only)')
    end
  end

  context 'when the document is restricted' do
    let(:doc) { FakeSolrDocument.new }

    before do
      doc.doc['access_level_ss'] = 'restricted'
      Blacklight.default_index.connection.add(doc.doc)
      Blacklight.default_index.connection.commit
    end

    it 'shows restricted to institution thumbnail' do
      visit "/catalog/#{doc.doc[:id]}"
      expect(page).to have_css("img[src*='restricted_icon']")
      expect(page).to have_content('Restricted')
    end
  end
end
