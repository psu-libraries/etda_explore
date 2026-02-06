# frozen_string_literal: true

class AutoRemediateWebhookService
  TRANSIENT_ERRORS = [
    Faraday::TimeoutError,
    Faraday::ConnectionFailed,
    Faraday::SSLError
  ].freeze

  def initialize(final_submission_file_id)
    @final_submission_file_id = final_submission_file_id
  end

  def notify
    payload = { final_submission_file_id: final_submission_file_id }
    headers = {
      'Content-Type' => 'application/json',
      'X-API-Key' => auto_remediate_webhook_token
    }

    conn = Faraday.new(
      url: "#{base_url}#{auto_remediate_webhook_path}",
      headers: headers
    )

    attempts = 0

    begin
      attempts += 1

      conn.post do |req|
        req.body = payload.to_json
      end
    rescue *TRANSIENT_ERRORS
      raise if attempts >= 5

      sleep(0.7 * (2**(attempts - 1))) # exponential backoff
      retry
    end
  end

  private

    attr_reader :final_submission_file_id

    def auto_remediate_webhook_token
      ENV.fetch("AUTO_REMEDIATE_WEBHOOK_TOKEN_#{current_partner.slug.upcase}")
    end

    def auto_remediate_webhook_path
      ENV.fetch('AUTO_REMEDIATE_WEBHOOK_PATH')
    end

    def base_url
      EtdaUtilities::Hosts.workflow_url
    end
end
