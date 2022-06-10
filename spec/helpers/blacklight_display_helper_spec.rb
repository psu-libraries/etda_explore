# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BlacklightDisplayHelper, type: :helper do
  describe '#render_as_list' do
    let(:keywords_doc) { { value: ['Keyword 1', 'Keyword 2'] } }

    it 'displays the list separated by line breaks' do
      keywords = render_as_list keywords_doc
      expect(keywords).to eq '<span>Keyword 1<br>Keyword 2</span>'
    end
  end
end
