# frozen_string_literal: true

class FilesController < ApplicationController
  include Blacklight::Document::SchemaOrg

  before_action :enforce_bot_challenge, only: :solr_download_final_submission

  def solr_download_final_submission
    token = files_params[:remediate_token]
    file_id = files_params[:id]
    remediated = ActiveModel::Type::Boolean.new.cast(files_params[:remediated])

    should_remediate =
      ENV['ENABLE_ACCESSIBILITY_REMEDIATION'] == 'true' && valid_remediate_token?(token, file_id)
    file_path = full_file_path(file_id, remediated)
    if file_path.nil?
      render plain: 'An Error has occurred', status: :internal_server_error
    else
      authorize! :read, @doc
      # We can remove the feature flag when we are confident in the new feature's performance
      if should_remediate
        AutoRemediateWebhookJob.perform_later(file_id)
      end
      send_file file_path, disposition: :inline
    end
  end

  private

    def files_params
      params.permit(:id, :remediated, :remediate_token)
    end

    def current_ability
      @current_ability ||= FileDownloadAbility.new(current_user, @doc)
    end

    def full_file_path(file_id, remediated)
      blacklight = Blacklight::Solr::Repository.new(CatalogController.blacklight_config)
      response = if remediated
                   blacklight.search(q: "remediated_final_submission_file_isim:#{file_id}")
                 else
                   blacklight.search(q: "final_submission_file_isim:#{file_id}")
                 end
      @doc = response.documents.first || nil

      @doc.file_by_id(file_id.to_i, @doc.access_level.current_access_level, remediated)
    end

    def enforce_bot_challenge
      # Challenge only if remote IP is not allowed
      allowed_ips = ENV.fetch('BOT_CHALLENGE_IP_WHITELIST', '')
        .split(',')
        .filter_map { |ip| IPAddr.new(ip.strip) unless ip.strip.empty? }
      return if allowed_ips.any? { |ip| ip.include?(IPAddr.new(request.remote_ip)) }

      BotChallengePage::BotChallengePageController.bot_challenge_enforce_filter(self, immediate: true)
    end

    def valid_remediate_token?(token, file_id)
      return false if token.nil? || token.blank?

      token_file_id = remediate_token_verifier.verify(token, purpose: :remediate_request)
      token_file_id.to_i == file_id.to_i
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      false
    end

    def remediate_token_verifier
      Rails.application.message_verifier(:remediate_request_token)
    end
end
