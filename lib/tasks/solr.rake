# frozen_string_literal: true
require 'etda_explore/solr_admin'
require_relative '../../app/models/fake_solr_document'

namespace :solr do
    desc 'Load Fixtures' 
    task load_fixtures: :environment do

      20.times do 
        doc = FakeSolrDocument.new
        Blacklight.default_index.connection.add(doc.doc)
        Blacklight.default_index.connection.commit
      end

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