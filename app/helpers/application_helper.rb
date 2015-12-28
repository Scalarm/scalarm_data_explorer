module ApplicationHelper
  def define_helper_functions
    render partial: 'application/define_helper_functions'
  end

  # Replaces image_url method, which gave url without @prefix consideration
  def prefixed_image_url(*args, &block)
    "#{@prefix}/#{image_path(*args, &block)}"
  end

  # Inserts a loading.gif (original size) which is initially hidden
  # using 'loading_chart_gif' class
  # @param [String] id id of result <img> element
  # @return [String] HTML code of <img> with loading.gif
  def loading_gif(id)
    image_tag(prefixed_image_url('loading.gif'),
              class: 'loading_chart_gif', id: id,
              style: 'display: none;')
  end

end
