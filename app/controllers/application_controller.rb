# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller

  layout :determine_layout if respond_to? :layout

  # Store the location before authentication for later redirect
  before_action :store_user_location!, if: :storable_location?

  rescue_from CanCan::AccessDenied, with: :access_denied

  def login
    if current_user && !current_user.guest?
      # Get the stored location or fall back to referer or home
      redirect_path = stored_location_for(:user) || session[:user_return_to] || request.referer || '/'
      # Clear the stored location
      session.delete(:user_return_to) if session[:user_return_to]
      redirect_to redirect_path, allow_other_host: false
    else
      # If not authenticated, the ingress will redirect to OAuth2
      redirect_to login_path
    end
  end

  def about; end

  private

    # Store the user's location for redirect after authentication
    # Only store for GET requests that are not AJAX and not already auth-related
    def storable_location?
      request.get? && is_navigational_format? && !devise_controller? && !request.xhr? && request.path != '/login'
    end

    def store_user_location!
      # Store location for later redirect after authentication
      store_location_for(:user, request.fullpath)
    end

    def access_denied
      redirect_to '/401', status: :unauthorized
    end
end
