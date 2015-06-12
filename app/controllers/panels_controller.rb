require 'scalarm/database/model'
require 'scalarm/database/core'

class PanelsController < ApplicationController



  # TODO: will be removed some day
  def index
    handle_panel_for_experiment
  end

  def show
    handle_panel_for_experiment
  end

  def handle_panel_for_experiment

    # TODO: security

    panels = Panels.new
    @methods = panels.methods
    @groups = panels.groups

    experiment_id = params[:id].to_s

    @experiment = Scalarm::Database::Model::Experiment.find_by_id(experiment_id)
    if @experiment.nil?
      raise 'No experiment'
    end

    # #params = @experiment.get_parameter_ids controler or model?
    render :index, :layout => false
  end

end
