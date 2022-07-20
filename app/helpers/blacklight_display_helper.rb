# frozen_string_literal: true

module BlacklightDisplayHelper
  # Given a list of items, displays each item on its own line
  include Blacklight::Document::SchemaOrg

  def render_as_list(options = {})
    content_tag :span, options[:value].join('<br>'), nil, false
  end

  def render_download_links(options = {})
    document = options.fetch(:document)
    access_level = document[:access_level_ss]

    if FileDownloadAbility.new(this_user, document).can? :read, document
      content_tag(
        :span,
        download_links(document),
        nil,
        false
      )
    elsif access_level == 'restricted'
      content_tag(
        :p, 'No files available due to restrictions.'
      )
    elsif this_user.guest?
      content_tag(
        :span,
        link_to('Login to Download', '/login'),
        nil,
        false
      )
    end
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

  def show_request_alternate(options = {})
    document = options.fetch(:document)
    return true if FileDownloadAbility.new(this_user, document).can? :read, document

    false
  end

  private

    def download_links(document)
      links = []

      document.final_submissions.each do |final_submission_id, name|
        links.append(
          content_tag(:span,
                      link_to(tag.i(class: 'fa fa-download download-link-fa') + "Download #{name}",
                              Rails.application.routes.url_helpers.final_submission_file_path(final_submission_id),
                              class: 'file-link form-control'))
        )
      end

      links.join
    end

    def facet_link(value, field)
      link_to(value, "/?f[#{field}][]=#{CGI.escape value}")
    end

    def this_user
      @this_user ||= current_or_guest_user
    end
end
