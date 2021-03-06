# frozen_string_literal: true

require 'rails_helper'

require 'fileutils'

RSpec.describe FilesController, type: :controller do
  context 'when open access' do
    let(:doc) { FakeSolrDocument.new }

    before do
      doc.doc[:access_level_ss] = 'open_access'
      doc.doc[:final_submission_file_isim] = ['123']
      Blacklight.default_index.connection.add(doc.doc)
      Blacklight.default_index.connection.commit
      FileUtils.mkpath 'tmp/open_access/23/123/'
      FileUtils.touch('tmp/open_access/23/123/thesis_1.pdf')
      @request.env['devise.mapping'] = Devise.mappings[:user]
      @request.headers['HTTP_X_AUTH_REQUEST_EMAIL'] = 'user1234@psu.edu'
      user = User.new(email: 'user1234@psu.edu')
      sign_in user
    end

    it 'returns favorably' do
      get :solr_download_final_submission, params: { id: doc.doc[:final_submission_file_isim].first }
      expect(response).to have_http_status(:ok)
    end
  end

  context 'when restricted to institution and logged out' do
    let(:doc) { FakeSolrDocument.new }

    before do
      doc.doc[:access_level_ss] = 'restricted_to_institution'
      doc.doc[:final_submission_file_isim] = ['1234']
      Blacklight.default_index.connection.add(doc.doc)
      Blacklight.default_index.connection.commit
      FileUtils.mkpath 'tmp/open_access/34/1234/'
      FileUtils.touch('tmp/open_access/34/1234/thesis_1.pdf')
    end

    it 'raises an error' do
      get :solr_download_final_submission, params: { id: doc.doc[:final_submission_file_isim].first }
      expect(response).to have_http_status(:unauthorized)
    end
  end

  context 'when restricted to institution and logged in' do
    let(:doc) { FakeSolrDocument.new }

    before do
      doc.doc[:access_level_ss] = 'restricted_to_institution'
      doc.doc[:final_submission_file_isim] = ['1235']
      Blacklight.default_index.connection.add(doc.doc)
      Blacklight.default_index.connection.commit
      FileUtils.mkpath 'tmp/restricted_institution/35/1235/'
      FileUtils.touch('tmp/restricted_institution/35/1235/thesis_1.pdf')
      @request.env['devise.mapping'] = Devise.mappings[:user]
      @request.headers['HTTP_X_AUTH_REQUEST_EMAIL'] = 'user1234@psu.edu'
      user = User.new(email: 'user1234@psu.edu')
      sign_in user
    end

    it 'returns a 200 message' do
      get :solr_download_final_submission, params: { id: doc.doc[:final_submission_file_isim].first }
      expect(response).to have_http_status(:ok)
    end
  end

  context 'when restricted' do
    let(:doc) { FakeSolrDocument.new }

    before do
      doc.doc[:access_level_ss] = 'restricted'
      doc.doc[:final_submission_file_isim] = ['1236']
      Blacklight.default_index.connection.add(doc.doc)
      Blacklight.default_index.connection.commit
      FileUtils.mkpath 'tmp/restricted_institution/36/1236/'
      FileUtils.touch('tmp/restricted_institution/36/1236/thesis_1.pdf')
      @request.env['devise.mapping'] = Devise.mappings[:user]
      @request.headers['HTTP_X_AUTH_REQUEST_EMAIL'] = 'user1234@psu.edu'
      user = User.new(email: 'user1234@psu.edu')
      sign_in user
    end

    it 'throws a server error' do
      get :solr_download_final_submission, params: { id: doc.doc[:final_submission_file_isim].first }
      expect(response).to have_http_status(:internal_server_error)
    end
  end
end
