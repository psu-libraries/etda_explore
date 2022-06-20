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

  describe '#render_as_facet_list' do
    let(:keywords_doc) {
      {
        value: ['Keyword 1', 'Keyword 2'],
        field: 'keyword_facet'
      }
    }

    it 'displays the list separated by line breaks' do
      keywords = render_as_facet_list keywords_doc
      expect(keywords).to eq '<span><a href="/?f[keyword_facet][]=Keyword+1">Keyword 1</a><br>' \
                                     '<a href="/?f[keyword_facet][]=Keyword+2">Keyword 2</a></span>'
    end
  end

  describe '#render_download_links' do
    let(:oa_doc) do
      {
        value: [1],
        document: {
          'access_level_ss' => 'open_access'
        }
      }
    end
    let(:rti_doc) do
      {
        value: [2],
        document: {
          'access_level_ss' => 'restricted_to_institution'
        }
      }
    end
    let(:r_doc) do
      {
        value: [3],
        document: {
          'access_level_ss' => 'restricted'
        }
      }
    end

    context 'when current_user is present' do
      before do
        allow_any_instance_of(described_class).to receive(:current_user).and_return 'test123@psu.edu'
      end

      it 'returns a link for open access and restricted to institution submissions' do
        expect(render_download_links(oa_doc)).to eq "<p>#{oa_doc.fetch(:value).first}</p>"
        expect(render_download_links(rti_doc)).to eq "<p>#{rti_doc.fetch(:value).first}</p>"
        expect(render_download_links(r_doc)).to eq "<p>No files available due to restrictions.</p>"
      end
    end

    context 'when current_user is not present' do
      before do
        allow_any_instance_of(described_class).to receive(:current_user).and_return nil
      end

      it 'only returns a link for open access submissions' do
        expect(render_download_links(oa_doc)).to eq "<p>#{oa_doc.fetch(:value).first}</p>"
        expect(render_download_links(rti_doc)).to eq "<p>No files available due to restrictions.</p>"
        expect(render_download_links(r_doc)).to eq "<p>No files available due to restrictions.</p>"
      end
    end
  end
end
