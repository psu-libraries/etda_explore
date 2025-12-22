# frozen_string_literal: true

class AutoRemediateWebhookJob < ApplicationJob
  queue_as :default

  # Retry failed HTTP requests with exponential backoff:
  # - Starts at 5 seconds and doubles each attempt
  # - Tries up to 8 times
  retry_on StandardError,
           attempts: 8,
           wait: ->(executions) { 5.seconds * (2**(executions - 1)) }

  def perform(final_submission_file_id)
    AutoRemediateWebhookService.new(final_submission_file_id: final_submission_file_id).call
  end
end
