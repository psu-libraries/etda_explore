# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module EtdaExplore
  class Application < Rails::Application
    require 'etda_explore/solr_config'
    require 'overrides/resumption_token'
    require 'healthchecks'

    config.solr = EtdaExplore::SolrConfig.new

    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # server custom error message pages
    config.exceptions_app = routes
  end
end
