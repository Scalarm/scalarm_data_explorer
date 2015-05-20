require 'scalarm/database/model'
require 'scalarm/database/core'

class PanelsController < ApplicationController

  PREFIX = '/'
  # def index
  #   render text: "Cokolwiek do wyswieltnbienia"
  # end
  def index

    # TODO: security
    # puts "hello world"
     @prefix = params[:base_url] || PREFIX
    #
     panels = Panels.new
     @methods = panels.methods
     @groups = panels.groups

    #@methods = []
    #@groups = []
     experiment_id = params[:id].to_s

     @experiment = Scalarm::Database::Model::Experiment.find_by_id(experiment_id)
     if @experiment.nil?
       raise 'No experiment'
     end
     Rails.logger.info @experiment
    # #params = @experiment.get_parameter_ids controler or model?
    #render :index, :layout => false
  end

  def show
  
    #render file: Rails.root.join( 
  end
end
