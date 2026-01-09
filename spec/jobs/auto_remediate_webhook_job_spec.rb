# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AutoRemediateWebhookJob do
  include ActiveJob::TestHelper
  include ActiveSupport::Testing::TimeHelpers

  before do
    ActiveJob::Base.queue_adapter = :test
    clear_enqueued_jobs
    clear_performed_jobs
  end

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end

  describe '#perform' do
    it 'delegates to AutoRemediateWebhookService on success' do
      final_id = 123
      service_double = instance_double(AutoRemediateWebhookService)

      allow(AutoRemediateWebhookService).to receive(:new)
        .with(final_id)
        .and_return(service_double)
      allow(service_double).to receive(:notify).and_return(true)

      described_class.perform_now(final_id)

      expect(AutoRemediateWebhookService).to have_received(:new)
        .with(final_id)
      expect(service_double).to have_received(:notify)
    end

    it 'enqueues the job' do
      final_id = 456

      expect {
        described_class.perform_later(final_id)
      }.to have_enqueued_job(described_class).with(final_id).on_queue('default')
    end

    it 'propagates errors when the service raises' do
      final_id = 789

      service_double = instance_double(AutoRemediateWebhookService)
      allow(AutoRemediateWebhookService).to receive(:new)
        .with(final_id)
        .and_return(service_double)
      allow(service_double).to receive(:notify).and_raise(StandardError, 'Error')

      expect {
        described_class.perform_now(final_id)
      }.to raise_error(StandardError, 'Error')
    end
  end
end
