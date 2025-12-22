# frozen_string_literal: true

class AutoRemediateWebhookService
  def initialize(final_submission_file_id)
    @final_submission_file_id = final_submission_file_id
  end

  def call
    payload = { final_submission_file_id: @final_submission_file_id }
    response = Faraday.post("#{base_url}#{auto_remediate_webhook_path}",
                            payload.to_json,
                            { 'Content-Type' => 'application/json' })

    unless response.status == 200
      raise "AutoRemediateWebhookService: HTTP #{response.status} response body=#{response.body.to_s[0, 500]}"
    end

    response
  end

  private

    attr_reader :final_submission_file_id

    def auto_remediate_webhook_path
      ENV.fetch('AUTO_REMEDIATE_WEBHOOK_PATH', nil)
    end

    def base_url
      EtdaUtilities::Hosts.workflow_url
    end
end
