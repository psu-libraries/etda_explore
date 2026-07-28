# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ErrorsController, type: :controller do
  subject { response }

  let(:non_html_format) do
    ext = Faker::File.extension

    ext == 'html' ? :xml : ext.to_sym
  end

  describe 'GET #not_found' do
    context 'with the default html format' do
      before { get :render_not_found }

      it { is_expected.to have_http_status(:not_found) }
    end

    context 'with any other specified format' do
      before { get :render_not_found, format: :non_html_format }

      it { is_expected.to have_http_status(:not_found) }
    end
  end

  describe 'GET #server_error' do
    context 'with the default html format' do
      before { get :render_server_error }

      it { is_expected.to have_http_status(:internal_server_error) }
    end

    context 'with any other specified format' do
      before { get :render_server_error, format: :non_html_format }

      it { is_expected.to have_http_status(:internal_server_error) }
    end
  end

  describe 'GET #unauthorized' do
    context 'with the default html format' do
      before { get :render_unauthorized }

      it { is_expected.to have_http_status(:unauthorized) }
    end

    context 'with any other specified format' do
      before { get :render_unauthorized, format: :non_html_format }

      it { is_expected.to have_http_status(:unauthorized) }
    end
  end
end
