class Interaction
  attr_accessor :experiment
  attr_accessor :parameters


  def prepare_interaction_chart_content(data)
    output = "<script>(function() { \nvar i=" + parameters["chart_id"] + ";";
    output += "\nvar data = " + data.to_json + ";" if data != nil
    output += "\ninteraction_main(i, \"" + parameters["param_x"] + "\", \"" + parameters["param_y"] + "\", data);";
    output += "\n})();</script>"
    output

  end


  def handler
    # dane parameters success error
    if parameters["id"] && parameters["chart_id"] && parameters["param_x"] && parameters["param_y"] && parameters["output"]

      data = getInteraction(parameters["param_x"], parameters["param_y"], parameters["output"])
      object = prepare_interaction_chart_content(data)
      object
    else
      error('Request parameters missing');
    end
  end


  def getInteraction(param_x, param_y, outputParam)

    simulation_runs = experiment.simulation_runs.to_a
    if simulation_runs.length == 0
      error("No such experiment or no runs done")
    end
    data = {}
    argument_ids = simulation_runs.first.arguments.split(',')
    params = {}
    simulation_runs = simulation_runs.map do |data|
      obj ={}
      values = data.values.split(',')
      new_args = {}

      argument_ids.each_with_index do |arg_name, index|
        params[arg_name] = params[arg_name].kind_of?(Array)? params[arg_name]<<values[index].to_f : [values[index].to_f]
        new_args[arg_name] = values[index].to_f
      end

      obj[:arguments] = new_args
      obj[:result] = {}
      unless data.result.nil?
        data.result.each do |key, value|
          obj[:result][key] = value.to_f rescue 0.0
        end
      end
      obj
    end
    mins = {}
    maxes = {}

    argument_ids.each do |arg_name|
      mins[arg_name] = params[arg_name].min
      maxes[arg_name] = params[arg_name].max
    end
    #simulation_runs[:arguments]
    low_low = {:result => {}}
    low_high = {:result => {}}
    high_low = {:result => {}}
    high_high = {:result => {}}
    simulation_runs.map do |data|
      if data[:arguments][param_x] == mins[param_x] && data[:arguments][param_y] == mins[param_y]
        low_low[:result] = data[:result]
      end

      if data[:arguments][param_x] == mins[param_x] && data[:arguments][param_y] == maxes[param_y]
        low_high[:result] = data[:result]

      end
      if data[:arguments][param_x] == maxes[param_x] && data[:arguments][param_y] == mins[param_y]
        high_low[:result] =  data[:result]

      end

      if data[:arguments][param_x] == maxes[param_x] && data[:arguments][param_y] == maxes[param_y]
        high_high[:result] = data[:result]
      end
  end
#gdy wartosc jest rowna min i max dla danych arg
   ## low_low =  simulation_runs[:arguments].select(param_x == mins[param_x]).select(param_y == mins[param_y])[0]
  #  low_high = array.select(param_x == mins[param_x]).select(param_y == maxes[param_y])[0]
   # high_low = array.select(param_x == maxes[param_x]).select(param_y == mins[param_y])[0]
   # high_high = array.select(param_x == maxes[param_x]).select(param_y == maxes[param_y])[0]
=begin
    Rails.logger.debug("###################################")
    Rails.logger.debug(low_low)
    Rails.logger.debug(low_high)
    Rails.logger.debug(high_low)
    Rails.logger.debug(high_high)
=end

    if (!low_low && low_high && high_low && high_high)
      raise ('Not enough data in database!')

    else
      result = []

      result.push(low_low.empty? ? 0 : low_low[:result][outputParam],
                  low_high.empty? ? 0 : low_high[:result][outputParam],
                  high_low.empty? ? 0 : high_low[:result][outputParam],
                  high_high.empty? ? 0 : high_high[:result][outputParam])

      data[param_x] = {domain: [mins[param_x], maxes[param_x]]}
      data[param_y] = {domain: [mins[param_y], maxes[param_y]]}

    end

    data[:effects] = result
    data
  end

end


