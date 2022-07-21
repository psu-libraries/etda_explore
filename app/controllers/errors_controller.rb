# frozen_string_literal: true

class ErrorsController < ApplicationController
  def internal_server_error
    render template: 'errors/500', formats: [:html, :json], status: :internal_server_error
  end

  def not_found
    render template: 'errors/404', formats: [:html, :json], status: :not_found
  end

  def unauthorized
    render template: 'errors/401', formats: [:html, :json], status: :unauthorized
  end
end
