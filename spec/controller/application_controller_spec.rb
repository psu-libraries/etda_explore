# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  context 'when coming from another page' do
    before do
      @request.env['devise.mapping'] = Devise.mappings[:user]
      @request.env['HTTP_REFERER'] = 'http://test.host/catalog?asdf'
      @request.headers['HTTP_X_AUTH_REQUEST_EMAIL'] = 'user1234@psu.edu'
      user = User.new(email: 'user1234@psu.edu')
      sign_in user
    end

    it 'redirects to referring page' do
      get :login
      expect(response).to redirect_to('/catalog?asdf')
    end
  end

  context 'when given the right headers' do
    before do
      @request.env['devise.mapping'] = Devise.mappings[:user]
      @request.headers['HTTP_X_AUTH_REQUEST_EMAIL'] = 'user1234@psu.edu'
      user = User.new(email: 'user1234@psu.edu')
      sign_in user
    end

    it 'redirects to index' do
      get :login
      expect(response).to redirect_to('/')
    end
  end

  context 'when given the wrong headers' do
    before do
      user = User.new(email: 'user1234@psu.edu')
      sign_in user
    end

    it 'redirects to login' do
      get :login
      expect(response).to redirect_to('/login')
    end
  end
end
