# frozen_string_literal: true
require 'etda_explore/solr_admin'

namespace :solr do
    desc 'Load Fixtures' 
    task load_fixtures: :environment do
      # TODO refactor

      docs = JSON.parse(File.open('spec/fixtures/current_fixtures.json').read)
      Blacklight.default_index.connection.add(docs)
      Blacklight.default_index.connection.commit

    end

    desc 'Initialize Solr'
    task init: :environment do
      puts "Starting initialization of Solr cores"
      conf = EtdaExplore::SolrAdmin.new
      conf.upload_config unless conf.configset_exists?
      conf.create_collection unless conf.collection_exists?
      conf.modify_collection
    end

end