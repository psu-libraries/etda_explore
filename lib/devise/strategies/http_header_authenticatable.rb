# frozen_string_literal: true

require 'devise/strategies/authenticatable'
module Devise
  module Strategies
    class HttpHeaderAuthenticatable < Authenticatable
      def authenticate!
        http_user = remote_user(request.headers)
        return fail! if http_user.blank?

        user = User.find_or_create_by(email: http_user)
        success!(user)
      end

      def valid?
        remote_user(request.headers).present?
      end

      def remote_user(headers)
        remote_user_header = ENV.fetch('REMOTE_USER_HEADER', 'HTTP_X_AUTH_REQUEST_EMAIL')
        headers.fetch(remote_user_header, nil)
      end
    end
  end
end

Warden::Strategies.add(:http_header_authenticatable, Devise::Strategies::HttpHeaderAuthenticatable)
