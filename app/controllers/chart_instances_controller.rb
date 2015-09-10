require 'erb'
class ChartInstancesController < ApplicationController
  before_filter :load_experiment, only: :show
  include ERB::Util

  def show
    analysisMethodsConfig = AnalysisMethodsConfig.new
    methods = analysisMethodsConfig.get_method_names
    #validating chart_id (name of method)
    validate(
        id: Proc.new do |param_name, value|
          unless methods.include? value
            raise "Wrong chart name"
          end
        end
    )

    chart_id = params[:id].to_s #nazwa metody

    filter = {is_done: true, is_error: {'$exists'=> false}}
    fields = {fields: {result: 1}}
    first_simulation_run = @experiment.simulation_runs.where(filter, fields).first

    params[:input_parameters] = @experiment.get_parameter_ids
    params[:moes] = first_simulation_run.blank? ? [] : first_simulation_run.result
    # class ogolna klasa z utilsami
    require_plugin(chart_id)

    #from 4.2 Rails version ... params html safety
    #params.transform_values {|v| ERB::Util.h(v)}

    #escaping html js all parameters for safety
    #params html safety (< 4.2 version)
    params.each do |parameter|
      params.update(params){ |k, v| ERB::Util.h(v)}
    end

    # set layout
    if params[:using_em] == 'true' || params[:using_em].nil?
      layout_value = false
    else
      layout_value = true
    end
    @content = generate_content_with_plugin(chart_id, @experiment, params)
    chart_header = render_to_string :file => Rails.root.join('app','visualisation_methods', chart_id, 'chart.html.haml'), layout: layout_value
    render :html => (chart_header + @content.to_s.html_safe), layout: false
  end

  def require_plugin(chart_id)
    path = Rails.root.join('app','visualisation_methods',"#{chart_id}","plugin")
    require(path)
  end

  def generate_content_with_plugin(chart_id, experiment, params)
    handler = chart_id.camelize.constantize.new
    handler.experiment = experiment
    handler.parameters = params
    handler.handler
  end
end