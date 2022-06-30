# frozen_string_literal: true

class SolrDocument
  include Blacklight::Solr::Document
  include BlacklightOaiProvider::SolrDocument

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

  self.timestamp_key = 'released_metadata_at_dtsi'

  # Dublin Core mappings for OAI endpoint
  field_semantics.merge!(
    title: 'title_ssi',
    creator: 'author_name_tesi',
    subject: 'keyword_ssim',
    coverage: 'program_name_ssi',
    relation: 'degree_name_ssi',
    description: 'abstract_tesi',
    contributor: 'committee_member_and_role_tesim',
    rights: 'access_level_ss',
    date: 'final_submission_files_uploaded_at_dtsi',
    identifier: 'id'
  )

  def to_semantic_values
    hash = super
    hash[:identifier] = ["#{EtdaUtilities::Hosts.explore_url}/catalog/#{hash[:identifier].first}"]
    hash[:date] = [Date.parse(hash[:date].first).strftime('%Y-%m-%dT%H:%M:%SZ')]
    hash
  end

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
