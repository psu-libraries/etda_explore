# frozen_string_literal: true

class AutoRemediateWebhookService
  def initialize(final_submission_file_id)
    @final_submission_file_id = final_submission_file_id
  end

  def notify
    connection.post do |req|
      req.body = { final_submission_file_id: final_submission_file_id }.to_json
    end
  end

  private

    attr_reader :final_submission_file_id

    def connection
      # Retries up to 5 times, doubling the wait each time (exponential backoff).
      Faraday.new(url: url, headers: headers) do |f|
        f.request :retry,
                  max: 5,
                  interval: 0.7,
                  backoff_factor: 2,
                  exceptions: Faraday::Retry::Middleware::DEFAULT_EXCEPTIONS
        f.adapter Faraday.default_adapter
      end
    end

    def url
      "#{base_url}#{auto_remediate_webhook_path}"
    end

    def headers
      {
        'Content-Type' => 'application/json',
        'X-API-Key' => auto_remediate_webhook_token
      }
    end

    def auto_remediate_webhook_token
      ENV.fetch('AUTO_REMEDIATE_WEBHOOK_TOKEN')
    end

    def auto_remediate_webhook_path
      ENV.fetch('AUTO_REMEDIATE_WEBHOOK_PATH')
    end

    def base_url
      EtdaUtilities::Hosts.workflow_url
    end
end
