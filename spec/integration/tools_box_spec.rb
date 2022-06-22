# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Tools box', type: :feature do
    before do
        @doc = FakeSolrDocument.new(access_level: 'open_access')
        Blacklight.default_index.connection.add(@doc.doc)
        Blacklight.default_index.connection.commit
    end

    it 'shows tools box' do
        visit "/catalog/#{@doc.doc[:id]}"
        expect(page).to have_css("a[class='file-link']")
        expect(page).to have_css("a[href*=#{@doc.doc[:final_submission_file_isim].first}]")
    end
end
