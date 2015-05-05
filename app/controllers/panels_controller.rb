class PanelsController < ApplicationController
  def index
  	panels = Panels.new()
  	@methods = panels.methods
  	@groups = panels.groups
    @experiment_id = params[:id]
  end
  def show
  
  	
    #render file: Rails.root.join( 
  end
end
