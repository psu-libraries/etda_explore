# frozen_string_literal: true

require 'rails_helper'
require 'support/matchers/blacklight'

RSpec.describe 'Catalog', type: :feature do
  let(:program_labels) { { 'graduate' => 'Graduate Program',
                           'honors' => 'Area of Honors',
                           'milsch' => 'Millennium Scholars Program' }
  }
  let(:program_label) { program_labels[current_partner.id] }

  let(:doc) { FakeSolrDocument.new.doc }

  before do
    doc[:access_level_ss] = 'open_access'
    doc[:defended_at_dtsi] = '2016-11-17T15:00:00Z'
    Blacklight.default_index.connection.add(doc)
    Blacklight.default_index.connection.commit
    visit '/catalog'
  end

  context 'when performs basic searches' do
    before do
      fill_in('q', with: doc[:title_ssi])
      click_button('Explore')
    end

    it 'displays all the fields in our index display correctly' do
      within("article[data-document-id=\"#{doc[:id]}\"]") do
        expect(page).to have_blacklight_label('author_name_tesi').with('Author')
        expect(page).to have_blacklight_field('author_name_tesi').with(doc[:author_name_tesi])
        expect(page).to have_blacklight_label('title_ssi').with('Title')
        expect(page).to have_blacklight_field('title_ssi').with(doc[:title_ssi])
        expect(page).to have_blacklight_label('program_name_ssi').with(program_label)
        expect(page).to have_blacklight_field('program_name_ssi').with(doc[:program_name_ssi])
        expect(page).to have_blacklight_label('keyword_ssim').with('Keywords')
        expect(page).to have_blacklight_field('keyword_ssim').with(doc[:keyword_ssim].first)
        expect(page).to have_blacklight_label('committee_member_and_role_tesim').with('Committee Members')
        expect(page).to have_blacklight_field('committee_member_and_role_tesim')
          .with(doc[:committee_member_and_role_tesim].first)
        expect(page).to have_link(doc[:title_ssi])
        expect(page).to have_blacklight_label('final_submission_file_isim').with('File')
        expect(page).to have_blacklight_field('final_submission_file_isim')
          .with("Download #{doc[:file_name_ssim].first}")
      end
    end

    it 'displays all the fields in our show display correctly' do
      click_link(doc[:title_ssi])
      expect(page).to have_content(doc[:title_ssi])
      expect(page).to have_blacklight_label('author_name_tesi').with('Author')
      expect(page).to have_blacklight_field('author_name_tesi').with(doc[:author_display])
      expect(page).to have_blacklight_label('program_name_ssi').with(program_label)
      expect(page).to have_blacklight_field('program_name_ssi').with(doc[:program_name_ssi])
      expect(page).to have_blacklight_label('degree_description_ssi').with('Degree')
      expect(page).to have_blacklight_field('degree_description_ssi').with(doc[:degree_description_ssi])
      expect(page).to have_blacklight_label('degree_type_ssi').with('Document Type')
      expect(page).to have_blacklight_field('degree_type_ssi').with(doc[:degree_type_ssi])
      expect(page).to have_blacklight_label('defended_at_dtsi').with('Date of Defense')
      expect(page).to have_blacklight_field('defended_at_dtsi').with('November 17, 2016')
      expect(page).to have_blacklight_label('committee_member_and_role_tesim').with('Committee Members')
      expect(page).to have_blacklight_field('committee_member_and_role_tesim')
        .with(doc[:committee_member_and_role_tesim].first)
      expect(page).to have_content('Open Access')
      expect(page).to have_blacklight_label('abstract_tesi').with('Abstract')
      expect(page).to have_blacklight_field('abstract_tesi').with(doc[:abstract_tesi])
      expect(page).to have_blacklight_label('keyword_ssim').with('Keywords')
      expect(page).to have_blacklight_field('keyword_ssim').with(doc[:keyword_ssim].first)
      expect(page).to have_link("Download #{doc[:file_name_ssim].first}")
      expect(page).to have_link('Request paper in alternate format')
    end
  end

  context 'when performs faceted browsing' do
    before do
      fill_in('q', with: doc[:committee_member_name_tesim].first)
      click_button('Explore')
    end

    it 'allows faceted browsing' do
      expect(page).to have_content(program_label)
      expect(page).to have_content('Degree')
      expect(page).to have_content('Year')
      expect(page).to have_content('Committee Member')
      expect(page).to have_content('Keyword')
      expect(page).to have_content('Author Last Name')
      expect(page).to have_content('Access Level')
      first('.blacklight-degree_name_ssi').click
      within('#facet-degree_name_ssi') do
        expect(page).to have_content(doc[:degree_name_ssi])
      end
      first('.blacklight-committee_member_name_ssim').click
      within('#facet-committee_member_name_ssim') do
        expect(page).to have_content(doc[:committee_member_name_tesim].first)
        # click_link "more"
      end
      # expect(page).to have_css(".modal-dialog")
      # expect(page).to have_content("Bebe Senger")
    end
  end

  context 'when performs searches on all fields' do
    before do
      select 'All Fields', from: 'Search in'
    end

    it 'finds an author' do
      fill_in('q', with: doc[:author_name_tesi])
      click_button 'Explore'
      # expect(page).to have_content('1 entry found')
      expect(page).to have_content(doc[:author_name_tesi])
    end

    it 'finds a title' do
      fill_in('q', with: doc[:title_ssi])
      click_button 'Explore'
      # expect(page).to have_content('1 entry found')
      expect(page).to have_content(doc[:title_ssi])
    end

    it 'finds a keyword' do
      fill_in('q', with: doc[:keyword_ssim].first)
      click_button 'Explore'
      # expect(page).to have_content('1 entry found')
      expect(page).to have_link(doc[:keyword_ssim].first)
    end

    it 'finds a committee member' do
      fill_in('q', with: doc[:committee_member_name_ssim].first)
      click_button 'Explore'
      # expect(page).to have_content('1 entry found')
      expect(page).to have_content(doc[:committee_member_name_ssim].first)
    end

    it 'finds a program' do
      fill_in('q', with: doc[:program_name_ssi])
      click_button 'Explore'
      # expect(page).to have_content('1 - 5 of 5')
      expect(page).to have_content("#{current_partner.program_label}: #{doc[:program_name_ssi]}")
    end

    it 'offers search instructions' do
      fill_in('q', with: 'zzzzzaaaaaa')
      click_button 'Explore'
      expect(page).to have_content('No results found')
      expect(page).to have_content('Try modifying your search')
    end
  end
end
