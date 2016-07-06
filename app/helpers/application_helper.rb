module ApplicationHelper
  def define_helper_functions
    render partial: 'application/define_helper_functions'
  end

  # Inserts a loading.gif (original size) which is initially hidden
  # using 'loading_chart_gif' class
  # @param [String] id id of result <img> element
  # @return [String] HTML code of <img> with loading.gif
  def loading_gif(id)
    image_tag(image_url('loading.gif'),
              class: 'loading_chart_gif', id: id,
              style: 'display: none;')
  end

end
