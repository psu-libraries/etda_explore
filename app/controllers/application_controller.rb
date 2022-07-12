# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  layout :determine_layout if respond_to? :layout

  rescue_from CanCan::AccessDenied, with: :render_401

  def login
    session[:redirect_url] = home_or_original_path
    if current_user
      redirect_to session[:redirect_url] || '/'
    else
      redirect_to login_path
    end
  end

  def about; end

  private

    def render_401
      render template: '/error/401', formats: [:html, :json], status: :unauthorized
    end

    def home_or_original_path
      return request.referer if request.referer

      '/'
    end
end
