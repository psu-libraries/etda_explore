# frozen_string_literal: true

module Devise
  class RedirectToLoginFailure < FailureApp
    def redirect_url
      '/login'
    end
  end
end
