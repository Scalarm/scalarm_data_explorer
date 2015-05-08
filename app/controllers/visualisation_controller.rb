class VisualisationController < ApplicationController
  def index
    visualisation = Visualisation.new()
    @parameters = visualisation.parameters

    @experiment_id = params[:id]


  end
  def show


    #render file: Rails.root.join(
  end
end