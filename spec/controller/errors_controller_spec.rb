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

      its(:status) { is_expected.to eq(404) }
    end

    context 'with any other specified format' do
      before { get :render_not_found, format: :non_html_format }

      its(:status) { is_expected.to eq(404) }
    end
  end

  describe 'GET #server_error' do
    context 'with the default html format' do
      before { get :render_server_error }

      its(:status) { is_expected.to eq(500) }
    end

    context 'with any other specified format' do
      before { get :render_server_error, format: :non_html_format }

      its(:status) { is_expected.to eq(500) }
    end
  end

  describe 'GET #unauthorized' do
    context 'with the default html format' do
      before { get :render_unauthorized }

      its(:status) { is_expected.to eq(401) }
    end

    context 'with any other specified format' do
      before { get :render_unauthorized, format: :non_html_format }

      its(:status) { is_expected.to eq(401) }
    end
  end
end
