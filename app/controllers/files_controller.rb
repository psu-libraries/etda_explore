# frozen_string_literal: true

class FilesController < ApplicationController
  include Blacklight::Document::SchemaOrg

  def solr_download_final_submission
    file_path = full_file_path(params[:id], params[:remediated])
    if file_path.nil?
      render plain: 'An Error has occurred', status: :internal_server_error
    else
      authorize! :read, @doc
      # We can remove the feature flag when we are confident in the new feature's performance
      if ENV['ENABLE_ACCESSIBILITY_REMEDIATION'] == 'true' && params[:remediated] != true
        AutoRemediateWebhookJob.perform_later(params[:id])
      end
      send_file file_path, disposition: :inline
    end
  end

  private

    def current_ability
      @current_ability ||= FileDownloadAbility.new(current_user, @doc)
    end

    def full_file_path(file_param_id, remediated)
      blacklight = Blacklight::Solr::Repository.new(CatalogController.blacklight_config)
      response = if remediated
                   blacklight.search(q: "remediated_final_submission_file_isim:#{file_param_id}")
                 else
                   blacklight.search(q: "final_submission_file_isim:#{file_param_id}")
                 end
      @doc = response.documents.first || nil

      @doc.file_by_id(file_param_id.to_i, @doc.access_level.current_access_level, remediated)
    end
end
