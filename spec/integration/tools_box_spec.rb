# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Tools box', :js, type: :feature do
  before do
    Blacklight.default_index.connection.add(doc)
    Blacklight.default_index.connection.commit
  end

  after do
    ENV['ENABLE_ACCESSIBILITY_REMEDIATION'] = @original_env_value
  end

  context 'when submissions is open access' do
    let(:doc) { FakeSolrDocument.new(access_level: 'open_access', file_ids: ['789'], remediated_file_ids: []).doc }

    before do
      visit "/catalog/#{doc[:id]}"
      @original_env_value = ENV.fetch('ENABLE_ACCESSIBILITY_REMEDIATION', nil)
      ENV['ENABLE_ACCESSIBILITY_REMEDIATION'] = 'true'
    end

    it 'shows download link and request alternate format link in tools' do
      expect(page).to have_css("a[class='file-link form-control download-trigger']")
      expect(page).to have_link("Download #{doc[:file_name_ssim].first}")
      expect(page).to have_link('Request paper in alternate format.')
    end

    it 'opens a modal for unremediated files' do
      visit "/catalog/#{doc[:id]}"
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

    context 'when file has been remediated' do
      let(:doc) do
        FakeSolrDocument.new(access_level: 'open_access', file_ids: ['789'], remediated_file_ids: ['720']).doc
      end

      before do
        FileUtils.mkpath 'tmp/open_access/remediated/20/720/'
        FileUtils.touch('tmp/open_access/remediated/20/720/remediated_thesis_1.pdf')
      end

      it 'does NOT open a modal for remediated files' do
        sleep 0.1
        expect(page).to have_no_content("Download #{doc[:file_name_ssim].first}")
        click_link "Download #{doc[:remediated_file_name_ssim].first}"
        expect(page).to have_no_css('#downloadModal')
        expect(page).to have_no_content(/Accessible Version in Progress|We're generating an accessible version/)
        expect(page).to have_no_link('OK')
      end
    end

    context 'when accessibility remediation is not enabled' do
      before do
        @original_env_value = ENV.fetch('ENABLE_ACCESSIBILITY_REMEDIATION', nil)
        ENV['ENABLE_ACCESSIBILITY_REMEDIATION'] = 'false'
        FileUtils.mkpath 'tmp/open_access/89/789/'
        FileUtils.touch('tmp/open_access/89/789/thesis_1.pdf')
      end

      it 'does not bring up a modal upon download', :js do
        click_link "Download #{doc[:file_name_ssim].first}"
        expect(page).to have_no_css('#downloadModal')
        expect(page).to have_no_content(/Accessible Version in Progress|We're generating an accessible version/)
        expect(page).to have_no_link('OK')
      end
    end
  end

  context 'when submissions is restricted to institution' do
    let(:doc) { FakeSolrDocument.new(access_level: 'restricted_to_institution', remediated_file_ids: []).doc }

    before do
      @original_env_value = ENV.fetch('ENABLE_ACCESSIBILITY_REMEDIATION', nil)
      ENV['ENABLE_ACCESSIBILITY_REMEDIATION'] = 'true'
    end

    context 'when user is logged in' do
      it 'shows download link and request alternate format link in tools' do
        allow_any_instance_of(BlacklightDisplayHelper)
          .to receive(:this_user).and_return User.create(email: 'test123@psu.edu', guest: false)
        visit "/catalog/#{doc[:id]}"
        click_link "Download #{doc[:file_name_ssim].first}"
        expect(page.driver.browser.switch_to.alert.text).to include(
          'You are attempting to download information that is restricted'
        )
        page.driver.browser.switch_to.alert.accept
        expect(page).to have_css('#downloadModal')
        expect(page).to have_content(/Accessible Version in Progress|We're generating an accessible version/)
      end
    end

    context 'when user is not logged in' do
      it 'shows login link and no request alternate format link in tools' do
        visit "/catalog/#{doc[:id]}"
        expect(page).to have_link('Login to Download')
        expect(page).to have_no_link('Request paper in alternate format.')
      end
    end
  end

  context 'when submissions is restricted' do
    let(:doc) { FakeSolrDocument.new(access_level: 'restricted').doc }

    it 'displays message that the file cannot be downloaded' do
      visit "/catalog/#{doc[:id]}"
      expect(page).to have_content 'No files available due to restrictions.'
      expect(page).to have_no_link('Request paper in alternate format.')
    end
  end
end
