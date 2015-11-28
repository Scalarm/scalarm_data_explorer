require 'scalarm/database/model'
require 'scalarm/database/core'
require 'erb'
class PanelsController < ApplicationController
  include ERB::Util
  before_filter :load_experiment, only: [:show, :index]


=begin
  apiDoc:
  @api {get} /panels/:id Main panel rendering
  @apiName panels#index
  @apiGroup Panels
  @apiDescription Returns main panel with all available analysis methods

  @apiParam {String} id ID of experiment

  @apiSuccess render panel view

=end
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

    if @experiment.nil?
      raise 'No experiment'
    end

    render :index, :layout => false
  end

end