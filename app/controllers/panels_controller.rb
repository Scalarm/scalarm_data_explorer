require 'scalarm/database/model'
require 'scalarm/database/core'

class PanelsController < ApplicationController

  before_filter :load_experiment, only: [:show, :index]

  # TODO: will be removed some day
  def index
    handle_panel_for_experiment
  end

  def show
    handle_panel_for_experiment
  end

  def handle_panel_for_experiment
    panels = Panels.new
    @methods = panels.methods
    @groups = panels.groups

    experiment_id = params[:id].to_s

    if @experiment.nil?
      raise 'No experiment'
    end

    # #params = @experiment.get_parameter_ids controler or model?
    render :index, :layout => false
  end

end