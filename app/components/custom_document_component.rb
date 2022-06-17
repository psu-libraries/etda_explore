# frozen_string_literal: true

class CustomDocumentComponent < Blacklight::DocumentComponent
  def access_level_display(document)
    contents = []
    badge_classes = 'badge col-md-7 mx-auto'
    access_level = document['access_level_ss']
    top_content = content_tag(:div,
                                 image_tag("#{document['access_level_ss']}_icon.png",
                                           alt: "#{document['access_level_ss']}",
                                           width: 175,
                                           class: 'mx-auto'),
                                 class: 'row')
    bottom_content = case access_level
                     when 'restricted_to_institution'
                       content_tag(:div, 'Restricted to PSU', class: badge_classes + ' badge-primary')
                     when 'restricted'
                       content_tag(:div, access_level.titleize, class: badge_classes + ' badge-danger')
                     else
                       content_tag(:div, access_level.titleize, class: badge_classes + ' badge-success')
                     end
    contents << top_content
    contents << content_tag(:div, bottom_content, class: 'row')
    content_tag(:div, contents.join(''), nil, false)
  end
end
