# frozen_string_literal: true

class AutoRemediateWebhookJob < ApplicationJob
  queue_as :default

  def perform(final_submission_file_id)
    AutoRemediateWebhookService.new(final_submission_file_id: final_submission_file_id).notify
  end
end
