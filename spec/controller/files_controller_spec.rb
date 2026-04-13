# frozen_string_literal: true

require 'rails_helper'

require 'fileutils'

RSpec.describe FilesController, type: :controller do
  let(:remediate_token_verifier) { Rails.application.message_verifier(:remediate_request_token) }
  let(:doc) { FakeSolrDocument.new }
  let(:file_id) { doc.doc[:final_submission_file_isim].first }
  let(:remediate_token) do
    remediate_token_verifier.generate(file_id, expires_in: 60, purpose: :remediate_request)
  end

  before do
    allow(AutoRemediateWebhookJob).to receive(:perform_later)
  end

  after do
    ENV['ENABLE_ACCESSIBILITY_REMEDIATION'] = @original_env_value
  end

  context 'when open access' do
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
      get :solr_download_final_submission, params: { id: file_id, remediate_token: }
      expect(response).to have_http_status(:ok)
    end

    context 'when ENABLE_ACCESSIBILITY_REMEDIATION is true' do
      before do
        @original_env_value = ENV.fetch('ENABLE_ACCESSIBILITY_REMEDIATION', nil)
        ENV['ENABLE_ACCESSIBILITY_REMEDIATION'] = 'true'
      end

      it 'triggers the AutoRemediateWebhookJob' do
        get :solr_download_final_submission, params: { id: file_id, remediate_token: }
        expect(AutoRemediateWebhookJob)
          .to have_received(:perform_later)
          .with(file_id)
      end

      it 'does not trigger the AutoRemediationJob if no remediate_token is provided' do
        get :solr_download_final_submission, params: { id: file_id }
        expect(AutoRemediateWebhookJob)
          .not_to have_received(:perform_later)
          .with(file_id)
      end

      it 'does not trigger the AutoRemediationJob if token does not match' do
        get :solr_download_final_submission, params: { id: file_id, remediate_token: 'bogus-token' }
        expect(AutoRemediateWebhookJob)
          .not_to have_received(:perform_later)
          .with(file_id)
      end
    end

    context 'when ENABLE_ACCESSIBILITY_REMEDIATION is not true' do
      before do
        @original_env_value = ENV.fetch('ENABLE_ACCESSIBILITY_REMEDIATION', nil)
        ENV['ENABLE_ACCESSIBILITY_REMEDIATION'] = 'false'
      end

      it 'does not triggers the AutoRemediateWebhookJob' do
        get :solr_download_final_submission, params: { id: file_id, remediate_token: }
        expect(AutoRemediateWebhookJob)
          .not_to have_received(:perform_later)
          .with(file_id)
      end
    end
  end

  context 'when restricted to institution and logged out' do
    before do
      doc.doc[:access_level_ss] = 'restricted_to_institution'
      doc.doc[:final_submission_file_isim] = ['1234']
      Blacklight.default_index.connection.add(doc.doc)
      Blacklight.default_index.connection.commit
      FileUtils.mkpath 'tmp/open_access/34/1234/'
      FileUtils.touch('tmp/open_access/34/1234/thesis_1.pdf')
    end

    it 'raises an error' do
      get :solr_download_final_submission, params: { id: file_id, remediate_token: }
      expect(response).to have_http_status(:unauthorized)
      expect(AutoRemediateWebhookJob).not_to have_received(:perform_later)
    end
  end

  context 'when restricted to institution and logged in' do
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
      get :solr_download_final_submission, params: { id: file_id, remediate_token: }
      expect(response).to have_http_status(:ok)
    end

    context 'when ENABLE_ACCESSIBILITY_REMEDIATION is true' do
      before do
        @original_env_value = ENV.fetch('ENABLE_ACCESSIBILITY_REMEDIATION', nil)
        ENV['ENABLE_ACCESSIBILITY_REMEDIATION'] = 'true'
      end

      it 'triggers the AutoRemediateWebhookJob' do
        get :solr_download_final_submission, params: { id: file_id, remediate_token: }
        expect(AutoRemediateWebhookJob)
          .to have_received(:perform_later)
          .with(file_id)
      end

      it 'does not trigger the AutoRemediationJob if no remediate_token is provided' do
        get :solr_download_final_submission, params: { id: file_id }
        expect(AutoRemediateWebhookJob)
          .not_to have_received(:perform_later)
          .with(file_id)
      end

      it 'does not trigger the AutoRemediationJob if token does not match' do
        get :solr_download_final_submission, params: { id: file_id, remediate_token: 'bogus-token' }
        expect(AutoRemediateWebhookJob)
          .not_to have_received(:perform_later)
          .with(file_id)
      end
    end

    context 'when ENABLE_ACCESSIBILITY_REMEDIATION is not true' do
      before do
        @original_env_value = ENV.fetch('ENABLE_ACCESSIBILITY_REMEDIATION', nil)
        ENV['ENABLE_ACCESSIBILITY_REMEDIATION'] = 'false'
      end

      it 'does not triggers the AutoRemediateWebhookJob' do
        get :solr_download_final_submission, params: { id: file_id, remediate_token: }
        expect(AutoRemediateWebhookJob)
          .not_to have_received(:perform_later)
          .with(file_id)
      end
    end
  end

  context 'when restricted' do
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
      get :solr_download_final_submission, params: { id: file_id, remediate_token: }
      expect(response).to have_http_status(:internal_server_error)
      expect(AutoRemediateWebhookJob).not_to have_received(:perform_later)
    end
  end
end
