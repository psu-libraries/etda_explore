# frozen_string_literal: true

class SolrDocument
  include Blacklight::Solr::Document

  # self.unique_key = 'id'

  # Email uses the semantic field mappings below to generate the body of an email.
  SolrDocument.use_extension(Blacklight::Document::Email)

  # SMS uses the semantic field mappings below to generate the body of an SMS email.
  SolrDocument.use_extension(Blacklight::Document::Sms)

  # DublinCore uses the semantic field mappings below to assemble an OAI-compliant Dublin Core document
  # Semantic mappings of solr stored fields. Fields may be multi or
  # single valued. See Blacklight::Document::SemanticFields#field_semantics
  # and Blacklight::Document::SemanticFields#to_semantic_values
  # Recommendation: Use field names from Dublin Core
  use_extension(Blacklight::Document::DublinCore)

  def access_level
    EtdaUtilities::AccessLevel.new(first(:access_level_ss))
  end

  def file_by_id(file_param_id, file_access_level)
    file_path = EtdaUtilities::EtdaFilePaths.new
    file_path.explore_download_file_path(file_param_id, file_access_level, final_submissions[file_param_id.to_i])
  end

  def final_submissions
    return {} if self[:final_submission_file_isim].blank?

    docs = {}
    self[:final_submission_file_isim].each_with_index do |id, index|
      docs[id] = self[:file_name_ssim][index]
    end
    docs
  end
end
