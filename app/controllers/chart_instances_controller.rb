class ChartInstancesController < ApplicationController
  before_filter :load_experiment, only: :show

  def show


        chart_id = params[:id].to_s #nazwa metody
    experiment_id = params[:experiment_id].to_s

    number_of_moes = params[:number_of_moes].to_i
    param_tab = []
    (0..number_of_moes-1).each do |i|
       param_tab[i] = params[:"param#{i+1}"].to_s
    end

    output = params[:output].to_s
    chart_counter = params[:chart_id].to_s
    type=  params[:type].to_s
    param1 = param_tab[0].to_s
    param2 = param_tab[1].to_s

    filter = {is_done: true, is_error: {'$exists'=> false}}
    fields = {fields: {result: 1}}
    @parameters = { "id" => chart_id }
    @parameters["param1"] = param1
    @parameters["param2"] = param2
    @parameters["chart_id"] = chart_counter
    @parameters["output"] = output
    @parameters["type"] = type
    @parameters["param_tab"] = param_tab
    #moes and input parameters
    moes = @experiment.simulation_runs.where(filter, fields).first
    @parameters["moes"] = moes.blank? ? [] : moes.result
    #add labels to method in scalarm_database -> experiment
    @parameters["input_parameters"]= @experiment.get_parameter_ids
    #require("visualisation_methods/#{chart_id}/#{chart_id}")

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