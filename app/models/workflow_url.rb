# frozen_string_literal: true

module WorkflowUrl

  class << self
    def call
      etda_utilities_hosts.workflow_submit_host(partner, host)
    end

    private

      def partner
        current_partner.id
      end

      def host
        ENV['WORKFLOW_HOST'] || 'prod'
      end

      def etda_utilities_hosts
        EtdaUtilities::Hosts.new
      end
  end
end