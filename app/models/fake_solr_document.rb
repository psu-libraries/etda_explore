# frozen_string_literal: true

class FakeSolrDocument
  attr_reader :doc

  def initialize(options = {})
    @options = options
    @doc = {
      year_isi: year,
      final_submission_files_uploaded_at_dtsi: final_submission_files_uploaded_at,
      id: id,
      access_level_ss: access_level,
      db_id: db_id,
      db_legacy_old_id: db_legacy_old_id,
      released_metadata_at_dtsi: released_metadata_at,
      title_tesi: title,
      title_ssi: title,
      db_legacy_id: db_legacy_id,
      abstract_tesi: abstract,
      semester_ssi: 'Spring',
      download_access_group_ssim: %w[public open_access],
      read_access_group_ssim: ['public'],
      final_submission_file_isim: file_ids,
      file_name_ssim: file_names,
      remediated_final_submission_file_isim: remediated_file_ids,
      remediated_file_name_ssim: remediated_file_names,
      author_name_tesi: author_name,
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
      committee_member_name_ssim: [committee_member_name],
      committee_member_name_tesim: [committee_member_name],
      committee_member_email_ssim: [committee_member_email],
      committee_member_and_role_tesim: committee_member_and_roles,
      committee_member_role_ssim: ['Advisor/Co-Advisor', 'Thesis Advisor/Co-Advisor'],
      keyword_ssim: keywords,
      keyword_tesim: keywords,
      defended_at_dtsi: defended_at
    }
  end

  private

    def title
      @title ||= @options[:title] || Faker::Hipster.sentence(word_count: 3)
    end

    def abstract
      @abstract ||= Faker::Hipster.sentence(word_count: 10)
    end

    def access_level
      @access_level ||= @options[:access_level] || %w[open_access restricted_to_institution restricted].sample
    end

    def name_generator
      @name_generator ||= Faker::Name
    end

    def last_name
      @last_name ||= name_generator.last_name
    end

    def first_name
      @first_name ||= name_generator.first_name
    end

    def middle_name
      @middle_name ||= name_generator.middle_name
    end

    def author_name
      @author_name ||= name_generator.name
    end

    def keywords
      @keywords ||= @options[:keywords] || Faker::Hipster.words(number: 5)
    end

    def committee_member_name
      @committee_member_name ||= name_generator.name
    end

    def committee_member_email
      @committee_member_email ||= Faker::Internet.email
    end

    def committee_member_and_roles
      @committee_member_and_roles ||= [
        "#{committee_member_name} Advisor/Co-Advisor",
        "#{name_generator.name} Thesis Advisor/Co-Advisor",
        "#{name_generator.name} Advisor/Co-Advisor",
        "#{name_generator.name} Thesis Advisor/Co-Advisor"
      ]
    end

    def file_names
      @file_names ||= @options[:file_names] || ['thesis_1.pdf']
    end

    def file_ids
      @file_ids ||= @options[:file_ids] || Array.new(file_names.count) { Faker::Number.unique.within(range: 1..1000) }
    end

    def remediated_file_ids
      @remediated_file_ids ||= @options[:remediated_file_ids] || if [true, false].sample
                                                                   Array.new(file_names.count) { Faker::Number.unique.within(range: 1..1000) }
                                                                 end
    end

    def remediated_file_names
      @remediated_file_names ||= file_names.map { |name| "remediated_#{name}" }
    end

    def released_metadata_at
      @released_metadata_at ||= @options[:released_metadata_at_dtsi] ||
        DateTime.parse(Faker::Date.between(from: 5.years.ago, to: Date.today).to_s).getutc
    end

    def defended_at
      @defended_at ||= Faker::Date.between(from: 5.years.ago, to: Date.today).strftime('%FT%TZ')
    end

    def year
      @year ||= Faker::Date.between(from: 5.years.ago, to: Date.today).year
    end

    def final_submission_files_uploaded_at
      @final_submission_files_uploaded_at ||= DateTime.parse(
        Faker::Date.between(from: 5.years.ago, to: Date.today).to_s
      ).getutc
    end

    def id
      @id ||= @options[:id] || Faker::Number.number(digits: 4)
    end

    def db_id
      @db_id ||= Faker::Number.unique.within(range: 1..1000)
    end

    def db_legacy_old_id
      @db_legacy_old_id ||= @options[:db_legacy_old_id] || Faker::Number.unique.within(range: 1..1000)
    end

    def db_legacy_id
      @db_legacy_id ||= Faker::Number.unique.within(range: 1..1000)
    end
end
