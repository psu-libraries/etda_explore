# frozen_string_literal: true

require 'etda_explore/solr_config'

module EtdaExplore
  class SolrAdmin
    def self.reset
      conf = new
      conf.delete_collection
      conf.delete_configset
      conf.upload_config
      conf.create_collection
    end

    attr_reader :config

    def initialize(config = SolrConfig.new)
      @config = config
    end

    def zip_file
      File.open(config.tempfile)
    end

    def configset_exists?
      config_sets.include?(config.configset_name)
    end

    def delete_configset
      resp = connection.get(SolrConfig::CONFIG_PATH, action: 'DELETE', name: config.configset_name)
      check_resp(resp)
    end

    def collection_exists?
      collections.include?(config.collection_name)
    end

    def delete_collection
      resp = connection.get(SolrConfig::COLLECTION_PATH, action: 'DELETE', name: config.collection_name)
      check_resp(resp)
    end

    def create_collection
      resp = connection.get(SolrConfig::COLLECTION_PATH,
                            action: 'CREATE',
                            name: config.collection_name,
                            numShards: config.num_shards,
                            'collection.configName': config.configset_name)
      check_resp(resp)
    end

    def modify_collection
      resp = connection.get(SolrConfig::COLLECTION_PATH,
                            action: 'MODIFYCOLLECTION',
                            collection: config.collection_name,
                            'collection.configName': config.configset_name)
      check_resp(resp)
    end

    def upload_config
      resp = connection.post(SolrConfig::CONFIG_PATH) do |req|
        req.params = { action: 'UPLOAD', name: config.configset_name }
        req.headers['Content-Type'] = 'octect/stream'
        req.body = raw_data
      end
      check_resp(resp)
    end

    private

      def raw_data
        @raw_data ||= zip_file.read
      end

      # Gets a response object, if it's status code is not 200, we emit the body and bail
      def check_resp(resp)
        raise resp.body unless resp.status == 200
      end

      def connection
        @connection ||= Faraday.new(config.url) do |faraday|
          if config.solr_username && config.solr_password
            faraday.request :authorization, :basic, config.solr_username, config.solr_password
          end
          faraday.adapter :net_http
        end
      end

      def config_sets
        list = connection.get(SolrConfig::CONFIG_PATH, action: 'LIST')
        JSON.parse(list.body)['configSets']
      end

      def collections
        resp = connection.get(SolrConfig::COLLECTION_PATH, action: 'LIST')
        JSON.parse(resp.body)['collections']
      end
  end
end
