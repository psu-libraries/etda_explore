# frozen_string_literal: true

require 'rails_helper'

describe 'Home page', type: :feature do
  shared_examples_for 'a page with the public layout' do
    it 'shows a link to the home page' do
      expect(page).to have_link current_partner.header_title, href: root_path
    end

    it 'shows a link to the about page' do
      expect(page).to have_link 'About', href: about_path
    end

    it 'shows a link to ETDA workflow' do
      expect(page).to have_link 'Add My Work', href: EtdaUtilities::Hosts.workflow_url
    end

    it 'shows Explore button to search' do
      expect(page).to have_button 'Explore'
    end

    it 'does not display Google Scholar meta tags' do
      expect(page).to have_no_css 'meta[@name="citation_title"]'
      expect(page).to have_no_css 'meta[@name="citation_author"]'
      expect(page).to have_no_css 'meta[@name="citation_publication_date"]'
      expect(page).to have_no_css 'meta[@name="citation_pdf_url"]'
    end
  end

  context 'when a user is logged in' do
    let(:user) { User.create email: 'user@test.com' }

    before do
      sign_in user
      visit root_path
    end

    it "shows the authenticated user's email" do
      expect(page).to have_content 'user@test.com'
    end

    it 'shows a sign out link' do
      expect(page).to have_link 'Log Out', href: destroy_user_session_path
    end

    it 'does not show a link to the login page' do
      expect(page).to have_no_link 'Login', href: login_path
    end

    it_behaves_like 'a page with the public layout'
  end

  context 'when the user is not logged in' do
    before { visit root_path }

    it 'shows a link to the login page' do
      expect(page).to have_link 'Login', href: login_path
    end

    it 'does not show a log out link' do
      expect(page).to have_no_link 'Log out', href: destroy_user_session_path
    end

    it_behaves_like 'a page with the public layout'
  end
end
