# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'The about page', type: :feature do
  before do
    allow(ENV).to receive(:fetch).and_call_original
    allow(ENV).to receive(:fetch).with('PARTNER').and_return(partner)
    visit about_path
  end

  context 'when current partner is graduate' do
    let(:partner) { 'graduate' }

    specify 'displays the partner header title' do
      expect(page).to have_content current_partner.header_title
    end

    specify 'descriptive text should be displayed for each partner' do
      expect(page).to have_content 'The primary purpose of a thesis or dissertation'
    end
  end

  context 'when current partner is honors' do
    let(:partner) { 'honors' }

    specify 'displays the partner header title' do
      expect(page).to have_content current_partner.header_title
    end

    specify 'descriptive text should be displayed for each partner' do
      expect(page).to have_content 'Electronic honors thesis and (eHTs) expand the creative'
    end
  end

  context 'when current partner is milsch' do
    let(:partner) { 'milsch' }

    specify 'displays the partner header title' do
      expect(page).to have_content current_partner.header_title
    end

    specify 'descriptive text should be displayed for each partner' do
      expect(page).to have_content 'The thesis is the culmination of each Millennium Scholar’s'
    end
  end

  context 'when current partner is sset' do
    let(:partner) { 'sset' }

    specify 'displays the partner header title' do
      expect(page).to have_content current_partner.header_title
    end

    specify 'descriptive text should be displayed for each partner' do
      expect(page).to have_content 'The primary purpose of the final paper is to train the student'
    end
  end
end
