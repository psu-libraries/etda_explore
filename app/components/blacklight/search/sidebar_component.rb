# frozen_string_literal: true

module Blacklight
  module Search
    class SidebarComponent < Blacklight::Component
      def initialize(blacklight_config:, response:, view_config:)
        @blacklight_config = blacklight_config
        @response = response
        @group_component_class = view_config.facet_group_component
      end

      def visible_facet_fields(groupname)
        facet_fields_in_group(groupname).select do |field|
          field.paginator&.items&.any?
        end
      end

      attr_reader :group_component_class, :response

      delegate :facet_group_names, :facet_fields_in_group, to: :@blacklight_config
    end
  end
end