# frozen_string_literal: true

module WorkflowUrl

  class << self
    def call
      if ENV['WORKFLOW_HOST']
        "https://#{ENV['WORKFLOW_HOST']}"
      else
        "https://" + etda_utilities_hosts.workflow_submit_host(partner, host)
      end
    end

    private

      def partner
        current_partner.id
      end

      def host
        Rails.application.secrets.stage || 'prod'
      end

      def etda_utilities_hosts
        EtdaUtilities::Hosts.new
      end
  end
end