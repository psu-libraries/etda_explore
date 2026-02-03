# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.4.1'

gem 'blacklight', '~> 8.12.3'
gem 'blacklight_oai_provider', github: 'projectblacklight/blacklight_oai_provider', ref: '69795b0'
gem 'bootsnap', require: false
gem 'bootstrap', '~> 5.1.3'
gem 'bot_challenge_page', '~> 0.3.0'
gem 'cancancan'
gem 'devise'
gem 'devise-guests', '~> 0.8'
gem 'etda_utilities'
gem 'faker'
gem 'faraday'
gem 'font-awesome-rails', '~> 4.7'
gem 'importmap-rails'
gem 'jbuilder'
gem 'jquery-rails'
gem 'mysql2', '>= 0.5.6'
gem 'okcomputer'
gem 'puma', '~> 6'
gem 'rails', '~> 7.2.2'
gem 'redis', '~> 4.0'
gem 'rsolr', '>= 1.0', '< 3'
gem 'sassc-rails', '~> 2.1'
gem 'simplecov'
gem 'sprockets-rails'
gem 'stimulus-rails'
gem 'turbo-rails'
gem 'twitter-typeahead-rails', '0.11.1.pre.corejavascript'
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem 'web-console'
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem 'capybara'
  gem 'rspec-its'
  gem 'rspec-rails'
  gem 'selenium-webdriver'
  gem 'webdrivers'
  gem 'webmock'
end

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'html_tokenizer', '~> 0.0.7'
  gem 'niftany', '>= 0.12'
  gem 'pry-byebug'
  gem 'solr_wrapper', '>= 0.3'
end
