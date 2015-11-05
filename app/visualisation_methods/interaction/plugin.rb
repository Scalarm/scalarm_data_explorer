class Interaction
  attr_accessor :experiment
  attr_accessor :parameters


  ##
  # create data for chart and <script> which is rendered in ChartInstancesController
  def handler
    if parameters["id"] && parameters["chart_id"] && parameters["param_x"].to_s && parameters["param_y"].to_s && parameters["output"].to_s

      data = get_interaction(experiment, parameters["param_x"].to_s, parameters["param_y"].to_s, parameters["output"].to_s)
      object = prepare_interaction_chart_content(data)
      object
    else
      raise('Request parameters missing');
    end
  end

  ##
  # create <script>> which is load on page
  def prepare_interaction_chart_content(data)
    output = "<script>(function() { \nvar i=" + parameters["chart_id"] + ";";
    output += "\nvar data = " + data.to_json + ";" if data != nil
    output += "\ninteraction_main(i, \"" + parameters["param_x"] + "\", \"" + parameters["param_y"] + "\", data);";
    output += "\n})();</script>"
    output

  end

  ##
  # prepare data for draw function
  #
  # Details:
  # Search for min and max values for each of  two input parameters
  # Compare if data is equal to  min or max values and when is get result(moes) data for these parameters
  # Four points are added to hash:
  # low_low (values of outputParam(moes) for min param_x and min param_y)
  # low_high (values of outputParam(moes) for min param_x and max param_y)
  # high_low (values of outputParam(moes) for max param_x and min param_y)
  # high_high (values of outputParam(moes) for max param_x and max param_y)
  # Funtion return hash with first values in array
  # for simulation where input parameters ids are x, y:
  # return {'x'=>{:domain=>[min_x, max_x]}, 'y'=>{:domain=>[min_y, max_y]}, :effects=>[low_low, low_high, high_low, high_high]}
  def get_interaction(experiment, param_x, param_y, outputParam)
    simulation_runs = experiment.simulation_runs.to_a
    if simulation_runs.length == 0
      raise('No such experiment or no runs done')
    end

    argument_ids = simulation_runs.first.arguments.split(',')
    params = {}
    simulation_runs = simulation_runs.map do |simulation_run|
      get_parameters(simulation_run, argument_ids, params)
    end

    mins = {}
    maxes = {}
    argument_ids.each do |arg_name|
      mins[arg_name] = params[arg_name].min
      maxes[arg_name] = params[arg_name].max
    end

    low_low = {:result => {}}
    low_high = {:result => {}}
    high_low = {:result => {}}
    high_high = {:result => {}}

    simulation_runs.map do |data|
      add_to_proper_hash(data, low_low, low_high, high_low, high_high, param_x, param_y, mins, maxes)
    end

    create_result_hash(low_low, low_high, high_low, high_high, mins, maxes, param_x, param_y, outputParam)
  end

  ##
  # get input and output parameters for simulation run, return hash: {:arguments=>{"parameter1"=>1.0, "parameter2"=>2.0}, :result=>{"product"=>3.0}}
  # in params on return is: {"parameter1"=>[array of value], "parameter2"=>[array of value]}
  def get_parameters(simulation_run, argument_ids, params)
    parameters ={}
    values = simulation_run.values.split(',')
    new_args = {}

    argument_ids.each_with_index do |arg_name, index|
      params[arg_name] = params[arg_name].kind_of?(Array)? params[arg_name]<<values[index].to_f : [values[index].to_f]
      new_args[arg_name] = values[index].to_f
    end

    parameters[:arguments] = new_args
    parameters[:result] = {}
    unless simulation_run.result.nil?
      simulation_run.result.each do |key, value|
        parameters[:result][key] = value.to_f rescue 0.0
      end
    end
    parameters
  end

  #
  # Compare if data is equal to min or max values, when is add result(moes) data for these parameters to proper hash
  def add_to_proper_hash(data, low_low, low_high, high_low, high_high, param_x, param_y, mins, maxes)
    if data[:arguments][param_x] == mins[param_x] && data[:arguments][param_y] == mins[param_y]
      # low_low[:result] = data[:result]
      low_low[:result].empty? ? low_low[:result] = [data[:result]] : low_low[:result].push(data[:result])
    end

    if data[:arguments][param_x] == mins[param_x] && data[:arguments][param_y] == maxes[param_y]
      low_high[:result].empty? ? low_high[:result] = [data[:result]] : low_high[:result].push(data[:result])
    end

    if data[:arguments][param_x] == maxes[param_x] && data[:arguments][param_y] == mins[param_y]
      high_low[:result].empty? ? high_low[:result] = [data[:result]] : high_low[:result].push(data[:result])
      # high_low[:result] =  data[:result]
    end

    if data[:arguments][param_x] == maxes[param_x] && data[:arguments][param_y] == maxes[param_y]
      high_high[:result].empty? ? high_high[:result] = [data[:result]] : high_high[:result].push(data[:result])
      # high_high[:result] = data[:result]
    end
  end

  # create finally hash with results of analysis
  # return {'x'=>{:domain=>[min_x, max_x]}, 'y'=>{:domain=>[min_y, max_y]}, :effects=>[low_low, low_high, high_low, high_high]
  def create_result_hash(low_low, low_high, high_low, high_high, mins, maxes, param_x, param_y, outputParam)
    data = {}
    if (low_low[:result].blank? && low_high[:result].blank? && high_low[:result].blank? && high_high[:result].blank?)
      raise ('Not enough data in database!')

    else
      result = []
      # first result from resultset as in prototype version
      result.push(low_low[:result].blank? ? 0 : low_low[:result][0][outputParam],
                  low_high[:result].blank? ? 0 : low_high[:result][0][outputParam],
                  high_low[:result].blank? ? 0 : high_low[:result][0][outputParam],
                  high_high[:result].blank? ? 0 : high_high[:result][0][outputParam])

      data[param_x] = {domain: [mins[param_x], maxes[param_x]]}
      data[param_y] = {domain: [mins[param_y], maxes[param_y]]}
    end
    data[:effects] = result
    data
  end
end


