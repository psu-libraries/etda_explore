# frozen_string_literal: true

class GoogleScholarMetadataComponent < ViewComponent::Base
  attr_reader :document

  def initialize(document)
    super
    @document = document.fetch(:document)
  end

  def citation_publication_date
    document[:released_metadata_at_dtsi]&.to_date&.year
  end

  def citation_pdf_url
    return nil unless document.access_level.current_access_level == 'open_access'

    document.final_submissions.each do |key, value|
      return final_submission_file_url(key) if File.extname(value) == '.pdf'
    end

    nil
  end
end
