class Lindev
  attr_accessor :experiment
  attr_accessor :parameters
  include Scalarm::ServiceCore::ParameterValidation


  ##
  # create data for chart and <script> which is rendered in ChartInstancesController
  def handler
    if parameters['id'] && parameters['param_x'].to_s && parameters['param_y'].to_s
      script_tag_for_chart = {}
      data = get_line_dev_data(experiment, parameters['param_x'].to_s, parameters['param_y'].to_s)
      if parameters['type'] == 'data'
        script_tag_for_chart = content[JSON.stringify(data)]
      elsif parameters['chart_id']
        script_tag_for_chart = prepare_lindev_chart_content(data)
      else
        raise MissingParametersError.new(["chart_id"])
      end
      script_tag_for_chart
    else
      raise MissingParametersError.new(["chart_id"])
    end
  end


  ##
  # create <script>> which is load on page
  def prepare_lindev_chart_content(data)
    output = "<script>(function() { \nvar i=" + parameters['chart_id'] + ';'
    output += "\nvar data = " + data.to_json + ';' if data != nil
    output += "\nlindev_main(i, \"" + parameters['param_x'] + "\", \"" + parameters['param_y'] + "\", data);"
    output += "\n})();</script>"
    output
  end


  ##
  # prepare data for draw function
  #
  # Details:
  # Function grouped result data as hash x => y (array)
  # Next it add pointers with standard deviation for each value in datahash
  def get_line_dev_data (experiment, param_x, param_y)
    simulation_runs = experiment.simulation_runs.to_a

    if simulation_runs.length == 0
      raise SecurityError.new("No such experiment or no simulation runs done")
    end

    # get input parameter names
    argument_ids = simulation_runs.first.arguments.split(',')

    simulation_runs = simulation_runs.map do |simulation_run|
      get_parameters(simulation_run, argument_ids)
    end

    #filling grouped_by_param_x with correct data
    grouped_by_param_x = grouping_by_parameter(argument_ids, {}, param_x, param_y, simulation_runs)

    get_values_and_std_dev(grouped_by_param_x)
  end

  ##
  # get input and output parameters for simulation run, return hash: {:arguments=>{"parameter1"=>1.0, "parameter2"=>2.0}, :result=>{"product"=>3.0}}
  def get_parameters(simulation_run, argument_ids)
    parameters ={}
    values = simulation_run.values.split(',')
    new_args = {}
    argument_ids.each_with_index do |arg_name, index|
      new_args[arg_name] = values[index].to_f
    end

    parameters[:arguments] = new_args
    parameters[:result] = {}
    #remove_instance_variable(data.values)
    unless simulation_run.result.nil?
      simulation_run.result.each do |key, value|
        parameters[:result][key] = value.to_f rescue 0.0
      end
    end
    parameters
  end


  ##
  # get parameters values from db and returns hash:    param x value => param y values (array)
  def grouping_by_parameter(argument_ids, grouped_by_param_x, param_x, param_y, simulation_runs)
    simulation_runs = simulation_runs.map do |obj|
      ## search for parameter value value in result or arguments
      param_x_val = argument_ids.index(param_x) ? obj[:arguments][param_x] : obj[:result][param_x]
      param_y_val = argument_ids.index(param_y) ? obj[:arguments][param_y] : obj[:result][param_y]

      if grouped_by_param_x.include? param_x_val
        grouped_by_param_x[param_x_val].push(param_y_val)
      else
        grouped_by_param_x[param_x_val] = [param_y_val]
      end
      obj
    end
    grouped_by_param_x
  end


  ##
  # return array where first argument is array of x values, and second is array with x values +- standard deviation
  # return array: [[[x1,y1],[x2,y2]],  [[x1, x1+standard_deviation, x1-standard_deviation],[x2, x2+std_dev, x2-std_dev]]]
  def get_values_and_std_dev(grouped_by_param_x)
    values = []
    with_stddev = []
    grouped_by_param_x.each do |key, value|
      if value.kind_of?(Array)
        values.push([key.to_f, value.mean])
        with_stddev.push([key.to_f, (value.mean-value.standard_deviation).to_f,(value.mean+value.standard_deviation).to_f])
      else
        values.push([key.to_f, value.to_f])
        with_stddev.push([key.to_f,value.to_f, value.to_f])

      end
    end
    values= values.sort_by { |e| e }
    with_stddev= with_stddev.sort_by { |e| e }
    [values, with_stddev]
  end
end

    