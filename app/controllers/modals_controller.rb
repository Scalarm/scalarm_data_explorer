class ModalsController < ApplicationController
  before_filter :load_experiment, only: :show


  ##
  # id -> id wykresu
  def show
    #params[]
    modal_content = render_to_string :file => Rails.root.join('app','visualisation_methods', chart_id, "_modal.html.haml"), layout: false
    chart_file_content = render_to_string :file => Rails.root.join('app','visualisation_methods', chart_id,"chart.js"), layout: false
    render :plain => modal_content + chart_file_content
  end



end
