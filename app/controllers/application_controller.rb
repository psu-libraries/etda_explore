# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  layout :determine_layout if respond_to? :layout

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

    def home_or_original_path
      return request.referer if request.referer

      '/'
    end
end
