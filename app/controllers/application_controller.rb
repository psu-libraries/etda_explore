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

  private
  
  def home_or_original_path
    original_fullpath = request.env.fetch('ORIGINAL_FULLPATH', '/')
    # prevent redirect loops when user hits /login directly
    return '/' if original_fullpath == '/login'

    original_fullpath
  end

end
