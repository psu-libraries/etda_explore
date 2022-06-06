# frozen_string_literal: true

namespace :solr do
    desc 'Load Fixtures' 
    task load_fixtures: :environment do
      # TODO refactor

      docs = JSON.parse(File.open('spec/fixtures/current_fixtures.json').read)
      Blacklight.default_index.connection.add(docs)
      Blacklight.default_index.connection.commit

    end
end