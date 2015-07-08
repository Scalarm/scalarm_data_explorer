class ChartInstancesController < ApplicationController
  before_filter :load_experiment, only: :show

  def show
    chart_id = params[:id].to_s #nazwa metody
    experiment_id = params[:experiment_id].to_s

    output = params[:output].to_s
    chart_counter = params[:chart_id].to_s
    type=  params[:type].to_s
    param1 = params[:param1].to_s
    param2 = params[:param2].to_s
    param3 = params[:param3].to_s

    filter = {is_done: true, is_error: {'$exists'=> false}}
    fields = {fields: {result: 1}}
    @parameters = { "id" => chart_id }
    @parameters["param1"] = param1
    @parameters["param2"] = param2
    #for 3dchart
    @parameters["param3"] = param3

    @parameters["chart_id"] = chart_counter
    @parameters["output"] = output
    @parameters["type"] = type
    #moes and input parameters
    moes = @experiment.simulation_runs.where(filter, fields).first
    @parameters["moes"] = moes.blank? ? [] : moes.result
    #add labels to method in scalarm_database -> experiment
    @parameters["input_parameters"]= @experiment.get_parameter_ids

    #if @experiment.visible_to(@current_user.id)
    path = Rails.root.join('app','visualisation_methods',"#{chart_id}","plugin")
    require(path)
    classname = chart_id.camelize.constantize.new
    classname.experiment = @experiment
    classname.parameters = @parameters
    @object = classname.handler
    chart_header =""
    #if(!@parameters["type"] || @parameters["type"]=="scalarm")
    chart_header = render_to_string :file => Rails.root.join('app','visualisation_methods', chart_id, "chart.html.haml"), layout: false
    #end
    render :html => (chart_header + @object.to_s.html_safe), layout: false

    #else
    #  raise 'Not authorised'
    #end

  end
end