class Interaction
  attr_accessor :experiment
  attr_accessor :parameters


  def prepare_interaction_chart_content(data)
    output = "<script>(function() { \nvar i=" + parameters["chart_id"] + ";";
    output += "\nvar data = " + data.to_json + ";" if data != nil
    output += "\ninteraction_main(i, \"" + parameters["param1"] + "\", \"" + parameters["param2"] + "\", data);";
    output += "\n})();</script>"
    output

  end


  def handler
    # dane parameters success error
    if parameters["id"] && parameters["chart_id"] && parameters["param1"] && parameters["param2"] && parameters["output"]

      data = getInteraction(parameters["param1"], parameters["param2"], parameters["output"])
      object = prepare_interaction_chart_content(data)
      object
    else
      error('Request parameters missing');
    end
  end


  def getInteraction(param1, param2, outputParam)

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
    Rails.logger.debug("###################")

    Rails.logger.debug(simulation_runs)
    #simulation_runs[:arguments]
    low_low = {:result => {}}
    low_high = {:result => {}}
    high_low = {:result => {}}
    high_high = {:result => {}}
    simulation_runs.map do |data|
      if data[:arguments][param1] == mins[param1] && data[:arguments][param2] == mins[param2]
        low_low[:result] = data[:result]
      end

      if data[:arguments][param1] == mins[param1] && data[:arguments][param2] == maxes[param2]
        low_high[:result] = data[:result]

      end
      if data[:arguments][param1] == maxes[param1] && data[:arguments][param2] == mins[param2]
        high_low[:result] =  data[:result]

      end

      if data[:arguments][param1] == maxes[param1] && data[:arguments][param2] == maxes[param2]
        high_high[:result] = data[:result]
      end
  end
#gdy wartosc jest rowna min i max dla danych arg
   ## low_low =  simulation_runs[:arguments].select(param1 == mins[param1]).select(param2 == mins[param2])[0]
  #  low_high = array.select(param1 == mins[param1]).select(param2 == maxes[param2])[0]
   # high_low = array.select(param1 == maxes[param1]).select(param2 == mins[param2])[0]
   # high_high = array.select(param1 == maxes[param1]).select(param2 == maxes[param2])[0]
    Rails.logger.debug("###################################")
    Rails.logger.debug(low_low)
    Rails.logger.debug(low_high)
    Rails.logger.debug(high_low)
    Rails.logger.debug(high_high)

    if (!low_low && low_high && high_low && high_high)
      raise ('Not enough data in database!')

    else
      result = []

      result.push(low_low.empty? ? 0 : low_low[:result][outputParam],
                  low_high.empty? ? 0 : low_high[:result][outputParam],
                  high_low.empty? ? 0 : high_low[:result][outputParam],
                  high_high.empty? ? 0 : high_high[:result][outputParam])

      data[param1] = {domain: [mins[param1], maxes[param1]]}
      data[param2] = {domain: [mins[param2], maxes[param2]]}

    end

    data[:effects] = result
    data
  end

end


