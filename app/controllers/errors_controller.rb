# frozen_string_literal: true

class ErrorsController < ApplicationController
  def render_server_error
    render template: 'errors/500', formats: [:html, :json], status: :internal_server_error
  end

  def render_not_found
    render template: 'errors/404', formats: [:html, :json], status: :not_found
  end

  def render_unauthorized
    render template: 'errors/401', formats: [:html, :json], status: :unauthorized
  end
end
