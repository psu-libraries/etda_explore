# frozen_string_literal: true

class LegacyRedirectController < ApplicationController
  def redirect_original_urls
    bl_object = Blacklight::Solr::Repository.new(CatalogController.blacklight_config)
    bl_response = bl_object.search(q: "db_legacy_old_id:#{params[:id]}")
    doc = bl_response.documents.first || nil
    new_id = doc.present? ? doc.id : nil
    if new_id.present?
      redirect_to "/catalog/#{new_id}", status: :moved_permanently
    else
      render template: '/errors/404', formats: [:html, :json], status: :not_found
    end
  end
end
