# frozen_string_literal: true
class FakeSolrDocument
    attr_reader :doc

    def initialize
        title = Faker::Hipster.sentence(word_count: 3)
        abstract = Faker::Hipster.sentence(word_count: 10)
        name = Faker::Name
        @doc = {
                "year_isi": Faker::Date.between(from: 5.years.ago, to: Date.today).year,
                "final_submission_files_uploaded_at_dtsi": Faker::Date.between(from: 5.years.ago, to: Date.today).rfc3339,
                "id": Faker::Number.number(digits: 4),
                "access_level_ss": "open_access",
                "db_id": Faker::Number.unique.within(range: 1..1000),
                "db_legacy_old_id": Faker::Number.unique.within(range: 1..1000),
                "released_metadata_at_dtsi": Faker::Date.between(from: 5.years.ago, to: Date.today).rfc3339,
                "title_tesi": title,
                "title_ssi": title,
                "db_legacy_id": Faker::Number.unique.within(range:1..1000),
                "abstract_tesi": abstract,
                "semester_ssi": "Spring",
                "download_access_group_ssim": [
                  "public",
                  "open_access"
                ],
                "read_access_group_ssim": [
                  "public"
                ],
                "final_submission_file_isim": [
                  1
                ],
                "file_name_ssim": [
                  "thesis_1.pdf"
                ],
                "author_name_tesi": name.name,
                "last_name_ssi": name.last_name,
                "last_name_tesi": name.last_name,
                "middle_name_ssi": name.middle_name,
                "first_name_ssi": name.first_name,
                "degree_name_ssi": "MS",
                "degree_description_ssi": "Master of Science",
                "degree_type_slug_ssi": "Master Thesis",
                "degree_type_ssi": "Master Thesis",
                "program_name_tesi": "Statistics",
                "program_name_ssi": "Statistics",
                "committee_member_name_ssim": [
                  name.name
                ],
                "committee_member_name_tesim": [
                  name.name
                ],
                "committee_member_email_ssim": [
                    Faker::Internet.email
                ],
                "committee_member_and_role_tesim": [
                  "#{name.name} Advisor/Co-Advisor",
                  "#{name.name} Thesis Advisor/Co-Advisor",
                  "#{name.name} Advisor/Co-Advisor",
                  "#{name.name} Thesis Advisor/Co-Advisor"
                ],
                "committee_member_role_ssim": [
                  "#{name.name} Thesis Advisor/Co-Advisor",
                  "Thesis Advisor/Co-Advisor"
                ],
                "keyword_ssim": Faker::Hipster.words(number: 5),
                "keyword_tesim": Faker::Hipster.words(number: 5)
        }
    end

end