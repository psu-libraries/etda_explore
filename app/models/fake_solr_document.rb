# frozen_string_literal: true
class FakeSolrDocument
    attr_reader :doc

    def initialize(access_level=nil)
        title = Faker::Hipster.sentence(word_count: 3)
        abstract = Faker::Hipster.sentence(word_count: 10)
        access_level_ss = ['restricted', 'open_access'].sample unless access_level
        name = Faker::Name
        semester = ['Spring', 'Summer', 'Fall'].sample
        file_name = Faker::File.file_name(ext: 'pdf').split('/')[1]
        last_name = name.last_name
        first_name = name.first_name
        middle_name = name.middle_name
        final_submission_file_isim = Faker::Number.unique.within(range: 1..7000)
        keywords = Faker::Hipster.words(number: 5)
        committee_member_name = name.name
        @doc = {
                "year_isi": Faker::Date.between(from: 5.years.ago, to: Date.today).year,
                "final_submission_files_uploaded_at_dtsi": Faker::Date.between(from: 5.years.ago, to: Date.today).rfc3339,
                "id": Faker::Number.number(digits: 4),
                "access_level_ss": access_level_ss,
                "db_id": Faker::Number.unique.within(range: 1..1000),
                "db_legacy_old_id": Faker::Number.unique.within(range: 1..1000),
                "released_metadata_at_dtsi": Faker::Date.between(from: 5.years.ago, to: Date.today).rfc3339,
                "title_tesi": title,
                "title_ssi": title,
                "db_legacy_id": Faker::Number.unique.within(range:1..1000),
                "abstract_tesi": abstract,
                "semester_ssi": semester,
                "download_access_group_ssim": [
                  "public",
                  "open_access"
                ],
                "read_access_group_ssim": [
                  "public"
                ],
                "final_submission_file_isim": [
                  final_submission_file_isim
                ],
                "file_name_ssim": [
                  file_name
                ],
                "author_name_tesi": name.name,
                "last_name_ssi": last_name,
                "last_name_tesi": last_name,
                "middle_name_ssi": middle_name,
                "first_name_ssi": first_name,
                "degree_name_ssi": "MS",
                "degree_description_ssi": degree_description_ssi,
                "degree_type_slug_ssi": "Master Thesis",
                "degree_type_ssi": "Master Thesis",
                "program_name_tesi": "Statistics",
                "program_name_ssi": "Statistics",
                "committee_member_name_ssim": [
                  committee_member_name
                ],
                "committee_member_name_tesim": [
                  committee_member_name
                ],
                "committee_member_email_ssim": [
                  Faker::Internet.email
                ],
                "committee_member_and_role_tesim": [
                  "#{committee_member_name} Advisor/Co-Advisor",
                  "#{name.name} Thesis Advisor/Co-Advisor",
                  "#{name.name} Advisor/Co-Advisor",
                  "#{name.name} Thesis Advisor/Co-Advisor"
                ],
                "committee_member_role_ssim": [
                  "Advisor/Co-Advisor",
                  "Thesis Advisor/Co-Advisor"
                ],
                "keyword_ssim": keywords,
                "keyword_tesim": keywords
        }
    end

    def degree_description_ssi

      [
        "Doctor of Education",
        "Doctor of Philosophy",
        "Master of Architecture",
        "Master of Arts",
        "Master of Engineering",
        "Master of Science"
      ].sample

    end

end