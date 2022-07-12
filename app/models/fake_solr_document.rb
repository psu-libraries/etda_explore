# frozen_string_literal: true

class FakeSolrDocument
  attr_reader :doc

  def initialize(options = {})
    title = Faker::Hipster.sentence(word_count: 3)
    abstract = Faker::Hipster.sentence(word_count: 10)
    access_level = options[:access_level] || ['open_access', 'restricted_to_institution', 'restricted'].sample
    name = Faker::Name
    last_name = name.last_name
    first_name = name.first_name
    middle_name = name.middle_name
    keywords = options[:keywords] || Faker::Hipster.words(number: 5)
    committee_member_name = name.name
    file_names = options[:file_names] || ['thesis_1.pdf']
    file_ids = Array.new(file_names.count) { Faker::Number.unique.within(range: 1..1000) }
    defended_at = Faker::Date.between(from: 5.years.ago, to: Date.today).strftime('%FT%TZ') # eg.'2016-11-17T15:00:00Z'
    @doc = {
      year_isi: Faker::Date.between(from: 5.years.ago, to: Date.today).year,
      final_submission_files_uploaded_at_dtsi: Faker::Date.between(from: 5.years.ago, to: Date.today).rfc3339,
      id: options[:id] || Faker::Number.number(digits: 4),
      access_level_ss: access_level,
      db_id: Faker::Number.unique.within(range: 1..1000),
      db_legacy_old_id: options[:db_legacy_old_id] || Faker::Number.unique.within(range: 1..1000),
      released_metadata_at_dtsi: Faker::Date.between(from: 5.years.ago, to: Date.today).rfc3339,
      title_tesi: title,
      title_ssi: title,
      db_legacy_id: Faker::Number.unique.within(range: 1..1000),
      abstract_tesi: abstract,
      semester_ssi: 'Spring',
      download_access_group_ssim: [
        'public',
        'open_access'
      ],
      read_access_group_ssim: [
        'public'
      ],
      final_submission_file_isim: file_ids,
      file_name_ssim: file_names,
      author_name_tesi: name.name,
      last_name_ssi: last_name,
      last_name_tesi: last_name,
      middle_name_ssi: middle_name,
      first_name_ssi: first_name,
      degree_name_ssi: 'MS',
      degree_description_ssi: 'Master of Science',
      degree_type_slug_ssi: 'Master Thesis',
      degree_type_ssi: 'Master Thesis',
      program_name_tesi: 'Statistics',
      program_name_ssi: 'Statistics',
      committee_member_name_ssim: [
        committee_member_name
      ],
      committee_member_name_tesim: [
        committee_member_name
      ],
      committee_member_email_ssim: [
        Faker::Internet.email
      ],
      committee_member_and_role_tesim: [
        "#{committee_member_name} Advisor/Co-Advisor",
        "#{name.name} Thesis Advisor/Co-Advisor",
        "#{name.name} Advisor/Co-Advisor",
        "#{name.name} Thesis Advisor/Co-Advisor"
      ],
      committee_member_role_ssim: [
        'Advisor/Co-Advisor',
        'Thesis Advisor/Co-Advisor'
      ],
      keyword_ssim: keywords,
      keyword_tesim: keywords,
      defended_at_dtsi: defended_at
    }
  end
end
