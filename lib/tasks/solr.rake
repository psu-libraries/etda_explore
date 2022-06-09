# frozen_string_literal: true
require 'etda_explore/solr_admin'
require_relative '../../app/models/fake_solr_document'

namespace :solr do

    desc 'Reset Solr'
    task reset: :environment do 
      conf = EtdaExplore::SolrAdmin.new
      conf.delete_all_collections
      conf.delete_all_configsets

      Rake::Task["solr:init"].invoke
    end

    desc 'Load Fixtures' 
    task :load_fixtures, [:num] => :environment do |_task, args|
      args.with_defaults(num: 20)

      args[:num].to_i.times do |index|
        puts "Adding Item #{index} to the collection"
        doc = FakeSolrDocument.new
        Blacklight.default_index.connection.add(doc.doc)
      end
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