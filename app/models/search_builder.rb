# frozen_string_literal: true

class SearchBuilder < Blacklight::SearchBuilder
  include Blacklight::Solr::SearchBuilderBehavior

  # Blacklight 9's advanced facet processor assumes a controller-backed
  # search state. OAI calls build a search service without a controller.
  def add_facets_for_advanced_search_form(solr_parameters)
    controller = search_state.respond_to?(:controller) ? search_state.controller : nil

    return unless controller.respond_to?(:action_name) &&
      controller.action_name == 'advanced_search' &&
      blacklight_config.advanced_search[:form_solr_parameters]

    solr_parameters.merge!(blacklight_config.advanced_search[:form_solr_parameters])
  end

  ##
  # @example Adding a new step to the processor chain
  #   self.default_processor_chain += [:add_custom_data_to_query]
  #
  #   def add_custom_data_to_query(solr_parameters)
  #     solr_parameters[:custom] = blacklight_params[:user_value]
  #   end
end
