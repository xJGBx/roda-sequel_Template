require 'sidekiq'
require 'sidekiq-cron'

class CleanupExpiredResetCodesJob
  include Sidekiq::Worker

  def perform
    User.where { reset_code_expires_at < Time.now }.update(reset_code: nil, reset_code_expires_at: nil)
  rescue StandardError => e
    logger.error("CleanupExpiredResetCodesJob failed: #{e.message}")
  end
end

Sidekiq::Cron::Job.create(
  name: 'Cleanup Expired Reset Codes - Every Day',
  cron: '0 0 * * *', # Runs at midnight
  class: 'CleanupExpiredResetCodesJob'
)
