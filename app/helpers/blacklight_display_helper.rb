# frozen_string_literal: true

module BlacklightDisplayHelper
  # Given a list of items, displays each item on its own line
  def render_as_list(options = {})
    content_tag :span, options[:value].join('<br>'), nil, false
  end

  def render_download_links(options = {})
    current_user = current_or_guest_user
    document = options.fetch(:document)
    access_level = document[:access_level_ss]

    if current_user.guest? && (access_level != 'open_access')

      content_tag(
        :span,
        link_to('Login to Download', '/login'),
        nil,
        false
      )
    else
      content_tag(
        :span,
        download_links(document),
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

  # TODO: This does not render links yet.  The path to the file and the download link needs to be added.
  # TODO: Currently, this just contains the access ability logic.
  # def render_download_links(options = {})
  #   value = options.fetch(:value, nil).first
  #   return if value.nil?

  #   document = options.fetch(:document)
  #   if current_user.present? && document['access_level_ss'] == 'restricted_to_institution'
  #     content_tag(:p, value)
  #   elsif document['access_level_ss'] == 'open_access'
  #     content_tag(:p, value)
  #   else
  #     content_tag(:p, 'No files available due to restrictions.')
  #   end
  # end

  private

    def download_links(document)
      links = []

      document.final_submissions.each do |final_submission_id, name|
        links.append(
          content_tag(:span,
                      link_to("Download #{name}",
                              Rails.application.routes.url_helpers.final_submission_file_path(final_submission_id)))
        )
      end

      links.join('')
    end

    def facet_link(value, field)
      link_to(value, "/?f[#{field}][]=#{CGI.escape value}")
    end
  
end
