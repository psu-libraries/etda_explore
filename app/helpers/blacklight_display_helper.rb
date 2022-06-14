# frozen_string_literal: true

module BlacklightDisplayHelper
  # Given a list of items, displays each item on its own line
  def render_as_list(options = {})
    content_tag :span, options[:value].join('<br>'), nil, false
  end

  # Given a list of items, displays each item as links on its own line
  def render_as_facet_list(options = {})
    field = options.fetch(:field)

    content_tag(
      :span,
      options[:value].map { |v| facet_link(v, field) }.join('<br>'),
      nil,
      false
    )
  end

  private

    def facet_link(value, field)
      link_to(value, "/?f[#{field}][]=#{CGI.escape value}")
    end
end
