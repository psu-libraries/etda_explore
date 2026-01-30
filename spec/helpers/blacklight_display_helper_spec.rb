# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BlacklightDisplayHelper do
  include DeviseGuests::Controllers::Helpers

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
      doc = SolrDocument.new(FakeSolrDocument.new(access_level: 'open_access',
                                                  remediated_file_ids: [11]).doc)
      {
        document: doc,
        value: doc[:final_submission_file_isim],
        field: 'final_submission_file_isim'
      }
    end
    let(:oa_doc_no_remediated) do
      doc = SolrDocument.new(FakeSolrDocument.new(access_level: 'open_access',
                                                  remediated_file_ids: []).doc)
      {
        document: doc,
        value: doc[:final_submission_file_isim],
        field: 'final_submission_file_isim'
      }
    end
    let(:rti_doc) do
      doc = SolrDocument.new(FakeSolrDocument.new(access_level: 'restricted_to_institution',
                                                  remediated_file_ids: [11]).doc)
      {
        document: doc,
        value: doc[:final_submission_file_isim],
        field: 'final_submission_file_isim'
      }
    end
    let(:rti_doc_no_remediated_multi_final_subs) do
      doc = SolrDocument.new(FakeSolrDocument.new(access_level: 'restricted_to_institution',
                                                  remediated_file_ids: [], file_ids: [1, 2]).doc)
      {
        document: doc,
        value: doc[:final_submission_file_isim],
        field: 'final_submission_file_isim'
      }
    end
    let(:r_doc) do
      doc = SolrDocument.new(FakeSolrDocument.new(access_level: 'restricted',
                                                  remediated_file_ids: []).doc)
      {
        document: doc,
        value: doc[:final_submission_file_isim],
        field: 'final_submission_file_isim'
      }
    end

    context 'when current_user is present' do
      before do
        user = User.new(email: 'test123@psu.edu', guest: false)
        allow_any_instance_of(described_class).to receive(:this_user).and_return user
      end

      it 'returns a link for open access and restricted to institution submissions' do
        expect(render_download_links(oa_doc)).to eq "<span><span><a class=\"file-link form-control\" href=\"/files/remediated_final_submissions/#{oa_doc[:document][:remediated_final_submission_file_isim].first}\"><i class=\"fa fa-download download-link-fa\"></i>Download #{oa_doc[:document][:remediated_file_name_ssim].first}</a></span></span>"
        expect(render_download_links(rti_doc)).to eq "<span><span><a data-confirm=\"#{I18n.t('registered.confirmation')}\" class=\"file-link form-control\" href=\"/files/remediated_final_submissions/#{rti_doc[:document][:remediated_final_submission_file_isim].first}\"><i class=\"fa fa-download download-link-fa\"></i>Download #{rti_doc[:document][:remediated_file_name_ssim].first}</a></span></span>"
        expect(render_download_links(r_doc)).to eq '<p>No files available due to restrictions.</p>'
      end

      it 'includes modal trigger attributes and modal only when no remediated files' do
        expect(render_download_links(oa_doc)).not_to include 'data-toggle="modal"'
        expect(render_download_links(rti_doc)).not_to include 'data-toggle="modal"'
        expect(render_download_links(r_doc)).not_to include 'data-toggle="modal"'
        expect(render_download_links(oa_doc_no_remediated)).to include('data-toggle="modal"').once
        expect(render_download_links(oa_doc_no_remediated)).to include "data-target=\"#downloadModal-#{oa_doc_no_remediated[:value].first}\""
        expect(render_download_links(oa_doc_no_remediated)).to include "id=\"downloadModal-#{oa_doc_no_remediated[:value].first}\""
        expect(render_download_links(oa_doc_no_remediated)).to include /Accessible Version in Progress|We're generating an accessible version/
        expect(render_download_links(oa_doc_no_remediated)).to have_link('OK',
                                                                         href: "/files/final_submissions/#{oa_doc_no_remediated[:value].first}")
        expect(render_download_links(rti_doc_no_remediated_multi_final_subs)).to include('data-toggle="modal"').twice
      end
    end

    context 'when current_user is not present' do
      before do
        user = User.new(email: 'test123@psu.edu', guest: true)
        allow_any_instance_of(described_class).to receive(:this_user).and_return user
      end

      it 'only returns a link for open access submissions' do
        expect(render_download_links(oa_doc)).to eq "<span><span><a class=\"file-link form-control\" href=\"/files/remediated_final_submissions/#{oa_doc[:document][:remediated_final_submission_file_isim].first}\"><i class=\"fa fa-download download-link-fa\"></i>Download #{oa_doc[:document][:remediated_file_name_ssim].first}</a></span></span>"
        expect(render_download_links(rti_doc)).to eq '<span><a href="/login">Login to Download</a></span>'
        expect(render_download_links(r_doc)).to eq '<p>No files available due to restrictions.</p>'
      end

      it 'includes modal trigger attributes and modal only when no remediated files' do
        expect(render_download_links(oa_doc)).not_to include 'data-toggle="modal"'
        expect(render_download_links(rti_doc)).not_to include 'data-toggle="modal"'
        expect(render_download_links(r_doc)).not_to include 'data-toggle="modal"'
        expect(render_download_links(oa_doc_no_remediated)).to include('data-toggle="modal"').once
        expect(render_download_links(oa_doc_no_remediated)).to include "data-target=\"#downloadModal-#{oa_doc_no_remediated[:value].first}\""
        expect(render_download_links(oa_doc_no_remediated)).to include "id=\"downloadModal-#{oa_doc_no_remediated[:value].first}\""
        # Not logged in so no modal for RTI
        expect(render_download_links(rti_doc_no_remediated_multi_final_subs)).not_to include 'data-toggle="modal"'
      end
    end

    context 'when document has remediated final submission' do
      context 'when current_user is the author' do
        before do
          user = User.new(email: oa_doc[:document][:author_email_ssi], guest: false)
          allow_any_instance_of(described_class).to receive(:this_user).and_return user
        end

        it 'returns links for both remediated and final submission files' do
          expect(render_download_links(oa_doc)).to include("<span><span><a class=\"file-link form-control\" href=\"/files/remediated_final_submissions/#{oa_doc[:document][:remediated_final_submission_file_isim].first}\"><i class=\"fa fa-download download-link-fa\"></i>Download #{oa_doc[:document][:remediated_file_name_ssim].first}</a></span>")
          expect(render_download_links(oa_doc)).to include("<span><a class=\"file-link form-control\" href=\"/files/final_submissions/#{oa_doc[:document].final_submissions.key(oa_doc[:document][:file_name_ssim].first)}\"><i class=\"fa fa-download download-link-fa\"></i>Download #{oa_doc[:document][:file_name_ssim].first}</a></span></span>")
        end
      end

      context 'when current_user is not the author' do
        before do
          user = User.new(email: 'test123@psu.edu', guest: false)
          allow_any_instance_of(described_class).to receive(:this_user).and_return user
        end

        it 'returns link for remediated submission file only' do
          expect(render_download_links(oa_doc)).to eq "<span><span><a class=\"file-link form-control\" href=\"/files/remediated_final_submissions/#{oa_doc[:document][:remediated_final_submission_file_isim].first}\"><i class=\"fa fa-download download-link-fa\"></i>Download #{oa_doc[:document][:remediated_file_name_ssim].first}</a></span></span>"
        end
      end
    end
  end
end
