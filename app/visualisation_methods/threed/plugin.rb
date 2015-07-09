class Threed

  attr_accessor :experiment
  attr_accessor :parameters

  def prepare_3d_chart_content(data)
    output = "<script>(function() { \nvar i=" + parameters["chart_id"] + ";"
    output += "\nvar data = " + data.to_json + ";" if data != nil
    output += "\nthreed_main(i, \"" + parameters["param1"] + "\", \"" + parameters["param2"] + "\", \"" + parameters["param3"] + "\", data);"
    output += "\n})();</script>"
    output

  end



  def handler
    if parameters["id"] && parameters["chart_id"] && parameters["param1"] && parameters["param2"] && parameters["param3"]
      data = get3d(parameters["param1"], parameters["param2"], parameters["param3"])
      object = prepare_3d_chart_content(data)
      object
    else
      error("Request parameters missing")
    end
  end



  def get3d(param1, param2, param3)
    simulation_runs = experiment.simulation_runs.to_a
    if simulation_runs.length == 0
      error("No such experiment or no runs done")
    end
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
    Rails.logger.debug(simulation_runs)
    argument_ids.each do |arg_name|
      mins[arg_name] = params[arg_name].min
      maxes[arg_name] = params[arg_name].max
    end

    data = []
    # TODO?
    #counter = Array.new(simulation_runs.size, &:next)
    #simulation_runs.size
    counter  = 0
    if argument_ids.index(param1)
      simulation_runs.map do |data_sim|

        data[counter] = [data_sim[:arguments][param1]]
        counter+=1
      end
    else
      simulation_runs.map do |data_sim|

        data[counter] = [data_sim[:result][param1]]
        counter+=1

      end
    end


    counter  = 0
    if argument_ids.index(param2)
      simulation_runs.map do |data_sim|

        data[counter].push(data_sim[:arguments][param2])
        counter+=1
      end
    else
      simulation_runs.map do |data_sim|

        data[counter].push(data_sim[:result][param2])
        counter+=1

      end
    end
    counter  = 0
    if argument_ids.index(param3)
      simulation_runs.map do |data_sim|

        data[counter].push(data_sim[:arguments][param3])
        counter+=1
      end
    else
      simulation_runs.map do |data_sim|

        data[counter].push(data_sim[:result][param3])
        counter+=1

      end
    end

    data
  end


end