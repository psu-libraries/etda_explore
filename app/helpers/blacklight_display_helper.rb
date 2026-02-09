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
      if document.remediated_final_submissions.any?
        links = remediated_final_submissions_links(document)
        links << final_submission_links(document) if this_user.email == document[:author_email_ssi]
      else
        links = final_submission_links(document)
      end

      links.join
    end

    def remediated_final_submissions_links(document)
      document.remediated_final_submissions.map do |remediated_final_submission_id, name|
        content_tag(:span,
                    link_to(tag.i(class: 'fa fa-download download-link-fa') + "Download #{name}",
                            Rails.application.routes.url_helpers.remediated_final_submission_file_path(remediated_final_submission_id),
                            data: { confirm: document.confirmation }, class: 'file-link form-control'))
      end
    end

    def final_submission_links(document)
      document.final_submissions.map do |final_submission_id, name|
        modal_trigger_options = if document.remediated_final_submissions.blank?
                                  { toggle: 'modal',
                                    target: "#downloadModal-#{final_submission_id}" }
                                end

        file_path = Rails.application.routes.url_helpers.final_submission_file_path(final_submission_id)
        data_options = { confirm: document.confirmation }.merge(modal_trigger_options || {})
        link_content = content_tag(:span,
                                   link_to(tag.i(class: 'fa fa-download download-link-fa') + "Download #{name}",
                                           file_path,
                                           data: data_options,
                                           class: 'file-link form-control'))

        if document.remediated_final_submissions.blank?
          link_content + render(partial: 'catalog/download_modal', locals: { final_submission_id: final_submission_id })
        else
          link_content
        end
      end
    end

    def facet_link(value, field)
      link_to(value, "/?f[#{field}][]=#{CGI.escape value}")
    end

    def this_user
      @this_user ||= current_or_guest_user
    end
end
