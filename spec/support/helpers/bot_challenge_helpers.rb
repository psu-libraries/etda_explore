# frozen_string_literal: true

module BotChallengeHelpers
  def with_bot_challenge_enabled
    challenge_controller = BotChallengePage::BotChallengePageController
    original_config = challenge_controller.bot_challenge_config

    challenge_controller.bot_challenge_config = original_config.dup
    challenge_controller.bot_challenge_config.enabled = true

    yield
  ensure
    challenge_controller.bot_challenge_config = original_config
  end
end
