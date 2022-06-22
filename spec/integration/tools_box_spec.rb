# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Tools box', type: :feature do
    before do
        Blacklight.default_index.connection.add(doc)
        Blacklight.default_index.connection.commit
    end

    context 'when submissions is open access' do
      let(:doc) { FakeSolrDocument.new(access_level: 'open_access').doc }

      it 'shows download link and request alternate format link in tools' do
        visit "/catalog/#{doc[:id]}"
        expect(page).to have_css("a[class='file-link']")
        expect(page).to have_css("a[href*=#{doc[:final_submission_file_isim].first}]")
        expect(page).to have_link('Request paper in alternate format.')
      end
    end

    context 'when submissions is restricted to institution' do
      let(:doc) { FakeSolrDocument.new(access_level: 'restricted_to_institution').doc }

      context 'when user is logged in' do
        it 'shows download link and request alternate format link in tools' do
          allow_any_instance_of(BlacklightDisplayHelper)
            .to receive(:this_user).and_return User.create(email: 'test123@psu.edu', guest: false)
          visit "/catalog/#{doc[:id]}"
          expect(page).to have_css("a[class='file-link']")
          expect(page).to have_css("a[href*=#{doc[:final_submission_file_isim].first}]")
          expect(page).to have_link('Request paper in alternate format.')
        end
      end

      context 'when user is not logged in' do
        it 'shows login link and no request alternate format link in tools' do
          visit "/catalog/#{doc[:id]}"
          expect(page).to have_link('Login to Download')
          expect(page).not_to have_link('Request paper in alternate format.')
        end
      end
    end

    context 'when submissions is restricted' do
      let(:doc) { FakeSolrDocument.new(access_level: 'restricted').doc }

      it 'displays message that the file cannot be downloaded' do
        visit "/catalog/#{doc[:id]}"
        expect(page).to have_content 'No files available due to restrictions.'
        expect(page).not_to have_link('Request paper in alternate format.')
      end
    end
end
