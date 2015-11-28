require 'scalarm/database/model'
require 'scalarm/database/core'
require 'erb'
class PanelsController < ApplicationController
  include ERB::Util
  before_filter :load_experiment, only: [:show]

=begin
 apiDoc:
  @api {get} /panels/:id Main panel rendering
  @apiName panels#show
  @apiGroup Panels
  @apiDescription Render html panel with links to available analysis methods with JavaScript functions and link to assistant.
  List of all visualisation methods is located in '/config/methods' as json.
  After clicking method link it invoke JavaScript function which call modal controller for content in order to create (when first time called) and show modal window.
  When assistant link is clicked it call prediction controller and create modal with selectable drop-downs.

  @apiParam {String} id ID of experiment


=end

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

    render :show, :layout => false
  end

end