class ScriptsController < ApplicationController
 
  def show
    #render experiment chart
    render file: Rails.root.join('app','visualisation_methods', params[:id], "chart.js") or raise not_found
  end
end
