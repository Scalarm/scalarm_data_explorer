require 'scalarm/database/model'
require 'scalarm/database/core'

class PanelsController < ApplicationController
  def index
    #add prefix

    @PREFIX = "/"
    if(params.has_key?(:base_url))
      @PREFIX = params[:base_url]
    end
  	panels = Panels.new()
  	@methods = panels.methods
  	@groups = panels.groups
    experiment_id = params[:id].to_s
    @experiment = Scalarm::Database::Model::Experiment.find_by_id(experiment_id)
    Rails.logger.info @experiment
    #params = @experiment.get_parameter_ids controler or model?
  end

  def show
  
    #render file: Rails.root.join( 
  end
end
