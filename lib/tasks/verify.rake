# frozen_string_literal: true

namespace :verify do
  desc 'Verify final submission files exist'
  task files: :environment do
    cursor_mark = '*'
    blacklight = Blacklight::Solr::Repository.new(CatalogController.blacklight_config)
    loop do
      response = blacklight.search(q: 'final_submission_file_isim:*', cursorMark: cursor_mark, sort: 'id asc', rows: 40)
      response.docs.each do |doc|
        doc.final_submissions.each do |k, _v|
          file_path = doc.file_by_id(k, doc.access_level.current_access_level)
          if file_path.nil?
            # EtdaUtils returns nil for restricted or empty access_levels
            next
          end

          unless File.exist?(file_path)
            Rails.logger.error("Document ID: #{doc.id} is missing at  #{file_path}")
          end
        end
      end
      break if cursor_mark == response['nextCursorMark']

      cursor_mark = response['nextCursorMark']
    end
  end
end
