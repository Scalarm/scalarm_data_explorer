module PanelsHelper

  def analysis_method_tooltip(description, image_name)
    content_tag(:div, description, style: 'width:65%;float:left;padding-top:10px;') +
        content_tag(:div, image_tag(image_name) , style: 'width:35%;float:right;')
  end

end
