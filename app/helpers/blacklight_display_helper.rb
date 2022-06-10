# frozen_string_literal: true

module BlacklightDisplayHelper
  # Given a list of items, displays each item on its own line
  def render_as_list(options = {})
    tag.span(options[:value].join('<br>'), nil, false)
  end
end
