# frozen_string_literal: true

require 'rails_helper'

describe 'Show page', :js, type: :feature do
  let!(:user) { User.create email: 'user@test.com' }
  let!(:doc_id) { '1234' }
  let!(:remed_doc_id) { '2345' }
  let!(:restricted_doc_id) { '3456' }
  let!(:doc) do
    FakeSolrDocument.new(id: doc_id, access_level: 'open_access', file_ids: ['789'], remediated_file_ids: []).doc
  end
  let!(:remed_doc) do
    FakeSolrDocument.new(id: remed_doc_id, access_level: 'open_access', file_ids: ['789'],
                         remediated_file_ids: ['720']).doc
  end
  let!(:restricted_doc) do
    FakeSolrDocument.new(id: restricted_doc_id, access_level: 'restricted_to_institution', file_ids: ['789'],
                         remediated_file_ids: []).doc
  end

  before do
    FileUtils.mkpath 'tmp/open_access/89/789/'
    FileUtils.touch('tmp/open_access/89/789/thesis_1.pdf')
    FileUtils.mkpath 'tmp/open_access/remediated/20/720/'
    FileUtils.touch('tmp/open_access/remediated/20/720/remediated_thesis_1.pdf')
    Blacklight.default_index.connection.add([doc, remed_doc, restricted_doc])
    Blacklight.default_index.connection.commit
  end

  after do
    ENV['ENABLE_ACCESSIBILITY_REMEDIATION'] = @original_env_value
  end

  context 'when accessibility remediation is enabled' do
    before do
      @original_env_value = ENV.fetch('ENABLE_ACCESSIBILITY_REMEDIATION', nil)
      ENV['ENABLE_ACCESSIBILITY_REMEDIATION'] = 'true'
    end

    it 'opens a modal for unremediated files' do
      visit solr_document_path(doc_id)
      click_link "Download #{doc[:file_name_ssim].first}"
      expect(page).to have_css('#downloadModal')
      expect(page).to have_content(/Accessible Version in Progress|We're generating an accessible version/)
      expect(page).to have_link('OK')
      expect(find_by_id('modalDownloadLink')[:href]).to include(
        "files/final_submissions/#{doc[:final_submission_file_isim].first}"
      )
      expect(find_by_id('modalDownloadLink')[:href]).to include('remediate_token')
      expect(find_by_id('modalDownloadLink')[:href]).to include('remediated=false')
    end

    it 'does NOT open a modal for remediated files' do
      visit solr_document_path(remed_doc_id)
      sleep 0.1
      expect(page).to have_no_content("Download #{remed_doc[:file_name_ssim].first}")
      click_link "Download #{remed_doc[:remediated_file_name_ssim].first}"
      expect(page).to have_no_css('#downloadModal')
      expect(page).to have_no_content(/Accessible Version in Progress|We're generating an accessible version/)
      expect(page).to have_no_link('OK')
    end

    it 'opens a confirmation, then a modal for unremediated restricted-to-inst files' do
      sign_in user
      visit solr_document_path(restricted_doc_id)
      click_link "Download #{doc[:file_name_ssim].first}"
      expect(page.driver.browser.switch_to.alert.text).to include(
        'You are attempting to download information that is restricted'
      )
      page.driver.browser.switch_to.alert.accept
      expect(page).to have_css('#downloadModal')
      expect(page).to have_content(/Accessible Version in Progress|We're generating an accessible version/)
    end
  end

  context 'when accessibility remediation is NOT enabled' do
    before do
      @original_env_value = ENV.fetch('ENABLE_ACCESSIBILITY_REMEDIATION', nil)
      ENV['ENABLE_ACCESSIBILITY_REMEDIATION'] = 'false'
    end

    it 'does not open a modal upon click' do
      visit solr_document_path('1234')
      click_link "Download #{doc[:file_name_ssim].first}"
      expect(page).to have_no_css('#downloadModal')
      expect(page).to have_no_content(/Accessible Version in Progress|We're generating an accessible version/)
      expect(page).to have_no_link('OK')
    end
  end
end
