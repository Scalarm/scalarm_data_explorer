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

    panels = Panels.new(params[:stand_alone])
    @methods = panels.methods
    @groups = panels.groups

    if @experiment.nil?
      raise 'No experiment'
    end

    if params[:stand_alone] == 'false' || params[:stand_alone].nil?
      layout_value = false
    else
      layout_value = true
    end

    render :index, :layout => layout_value
  end

end