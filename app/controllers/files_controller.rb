# frozen_string_literal: true

class FilesController < ApplicationController
  def solr_download_final_submission
    blacklight = Blacklight::Solr::Repository.new(CatalogController.blacklight_config)
    response = blacklight.search(q: "final_submission_file_isim:#{params[:id]}")
    @doc = response.documents.first || nil

    full_file_path = @doc.file_by_id(params[:id].to_i, @doc.access_level.current_access_level)
    authorize! :read, @doc
    send_file full_file_path, disposition: :inline
  end

  private

    def current_ability
      @current_ability ||= FileDownloadAbility.new(current_user, @doc)
    end
end
