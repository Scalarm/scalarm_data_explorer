class ChartInstancesController < ApplicationController
  before_filter :load_experiment, only: :show

  def show


    chart_id = params[:id].to_s #nazwa metody

    filter = {is_done: true, is_error: {'$exists'=> false}}
    fields = {fields: {result: 1}}
    moes = @experiment.simulation_runs.where(filter, fields).first

    params[:input_parameters] = @experiment.get_parameter_ids
    params[:moes] = moes.blank? ? [] : moes.result

    path = Rails.root.join('app','visualisation_methods',"#{chart_id}","plugin")
    require(path)

    handler = chart_id.camelize.constantize.new
    handler.experiment = @experiment
    handler.parameters = params#@parameters

    @content = handler.handler
    chart_header =""
    #if(!@parameters["type"] || @parameters["type"]=="scalarm")
    chart_header = render_to_string :file => Rails.root.join('app','visualisation_methods', chart_id, "chart.html.haml"), layout: false
    #end
    render :html => (chart_header + @content.to_s.html_safe), layout: false

    #else
    #  raise 'Not authorised'
    #end

  end
end