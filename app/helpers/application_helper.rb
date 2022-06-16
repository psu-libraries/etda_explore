# frozen_string_literal: true

module ApplicationHelper
  def render_page_title
    "#{current_partner.slug} Explore"
  end
end
