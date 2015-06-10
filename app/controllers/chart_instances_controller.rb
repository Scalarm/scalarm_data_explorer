class ChartInstancesController < ApplicationController
  PREFIX = "/"
  def show
    chart_id = params[:id].to_s #nazwa metody
    experiment_id = params[:experiment_id].to_s
    @experiment = Scalarm::Database::Model::Experiment.find_by_id(experiment_id)
    @prefix = params[:base_url] || PREFIX
    output = params[:output].to_s
    chart_counter = params[:chart_id].to_s
    type=  params[:type].to_s
    param1 = params[:param1].to_s
    param2 = params[:param2].to_s

    filter = {is_done: true, is_error: {'$exists'=> false}}
    fields = {fields: {result: 1}}
    @parameters = { "id" => chart_id }
    @parameters["param1"] = param1
    @parameters["param2"] = param2
    @parameters["chart_id"] = chart_counter
    @parameters["output"] = output
    @parameters["type"] = type
    @parameters["moes"] = @experiment.simulation_runs.where(filter, fields).first.result
    @parameters["input_parameters"]= @experiment.get_parameter_ids
    #require("visualisation_methods/#{chart_id}/#{chart_id}")

# dodac moes oraz input parameters
  	#if @experiment.visible_to(@current_user.id)
      path = Rails.root.join('app','visualisation_methods',"#{chart_id}","plugin")
      require(path)
      classname = chart_id.camelize.constantize.new
      classname.experiment = @experiment
      classname.parameters = parameters
      object = classname.handler
      chart_header =""
      if(!parameters["type"] || parameters["type"]=="scalarm")
        chart_header = render_to_string :file => Rails.root.join('app','visualisation_methods', chart_id, "chart.html.haml")
      end
      render :text => chart_header + object[:content]
  	#else
  	#  raise 'Not authorised'
  	#end
  end
end
