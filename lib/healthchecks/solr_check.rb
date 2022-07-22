# frozen_string_literal: true

module HealthChecks
  class SolrCheck < OkComputer::Check
    def check
      solr = RSolr.connect(url: Rails.configuration.solr.query_url)
      resp = solr.get('admin/ping')
      status = resp&.dig('status')
      zk_connected = resp&.dig('responseHeader')&.dig('zkConnected')
      @message = Hash.new
      @message['zkConnected'] = zk_connected
      @message['status'] = status
      mark_message(@message)
      mark_failure unless status == 'OK'
      mark_failure unless zk_connected == true
    end
  end
end
