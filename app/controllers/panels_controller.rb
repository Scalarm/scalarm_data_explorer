require 'scalarm/database/model'
require 'scalarm/database/core'
require 'erb'
class PanelsController < ApplicationController
  include ERB::Util
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

    experiment_id = ERB::Util.h(params[:id].to_s)

    if @experiment.nil?
      raise 'No experiment'
    end

    # #params = @experiment.get_parameter_ids controler or model?
    render :index, :layout => false
  end

end