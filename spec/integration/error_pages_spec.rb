# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Custom error page', type: :feature do
  context 'when responding to a 404 error' do
    it 'links to the libraries contact form' do
      visit '/catalog/xxxx'
      expect(page).to have_content("#{current_partner.slug} tried to process your request but encountered an error.")
      expect(page.status_code).to eq(404)
      expect(page).to have_content('404')
      expect(page).to have_link('reporting this error', href: I18n.t('libraries_help_link'))
    end
  end
end
