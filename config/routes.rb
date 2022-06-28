# frozen_string_literal: true

Rails.application.routes.draw do
  mount Blacklight::Engine => '/'
  root to: 'catalog#index'
  concern :searchable, Blacklight::Routes::Searchable.new
  concern :oai_provider, BlacklightOaiProvider::Routes.new

  authenticate :user do
    get '/login', to: 'application#login', as: :login
  end

  resource :catalog, only: [:index], as: 'catalog', path: '/catalog', controller: 'catalog' do
    concerns :searchable
    concerns :oai_provider
  end
  devise_for :users

  concern :exportable, Blacklight::Routes::Exportable.new

  resources :solr_documents, only: [:show], path: '/catalog', controller: 'catalog' do
    concerns :exportable
  end

  resources :bookmarks do
    concerns :exportable

    collection do
      delete 'clear'
    end
  end

  get '/about', to: 'application#about'
  get '/files/final_submissions/:id', to: 'files#solr_download_final_submission', as: :final_submission_file

  # Legacy Redirects
  get '/theses/approved/:access_level/:id_prefix-:id/(:all)',
      to: 'legacy_redirect#redirect_original_urls',
      constraints: { id_prefix: /E(:?HT|TD)/, access_level: /WorldWideIndex|PSUonlyIndex|WithheldIndex/ }
  get '/paper/:id/(:all)', to: redirect('/catalog/%{id}'), status: 301
  get '/search', to: redirect('/catalog'), status: 301
  get '/browse', to: redirect('/catalog'), status: 301

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
