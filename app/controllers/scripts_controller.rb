class ScriptsController < ApplicationController
 
  def show
    #render experiment chart
    render file: Rails.root.join('app','visualisation_methods', params[:id], "chart.js"),  layout: false
  end
end
