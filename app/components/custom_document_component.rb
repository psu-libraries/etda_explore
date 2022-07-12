# frozen_string_literal: true

class CustomDocumentComponent < Blacklight::DocumentComponent
  def access_level_display
    contents = []
    badge_classes = 'badge col-md-10'
    access_level = document['access_level_ss']
    top_content = tag.div(image_tag("#{document['access_level_ss']}_icon.png",
                                    alt: document['access_level_ss'].to_s,
                                    width: 160), class: 'row justify-content-center')
    bottom_content = case access_level
                     when 'restricted_to_institution'
                       tag.span('Restricted (Penn State Only)', class: "#{badge_classes} badge-primary text-wrap")
                     when 'restricted'
                       tag.span(access_level.titleize, class: "#{badge_classes} badge-danger")
                     else
                       tag.span(access_level.titleize, class: "#{badge_classes} badge-success")
                     end
    contents << top_content
    contents << tag.div(bottom_content, class: 'row justify-content-center')
    content_tag(:div, contents.join, nil, false)
  end

  private

    def document
      @document
    end
end
