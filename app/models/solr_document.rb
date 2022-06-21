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

  # Dublin Core mappings for OAI endpoint
  field_semantics.merge!(
    title: "title_ssi",
    creator: "author_name_tesi",
    subject: "keyword_ssim",
    coverage: "program_name_ssi",
    relation: "degree_name_ssi",
    description: "abstract_tesi",
    contributor: "committee_member_and_role_tesim",
    rights: "access_level_ss",
    date: "final_submission_files_uploaded_at_dtsi",
    timestamp: "released_metadata_at_dtsi",
    identifier: "id"
  )

  def to_semantic_values
    hash = super
    hash[:identifier] = ["#{EtdaUtilities::Hosts.explore_url}/catalog/#{hash[:identifier].first}"]
    hash[:date] = [Date.parse(hash[:date].first).strftime('%Y-%m-%dT%H:%M:%SZ')]
    hash
  end
end
