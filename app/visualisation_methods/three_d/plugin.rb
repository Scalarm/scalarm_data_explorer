class ThreeD

  attr_accessor :experiment
  attr_accessor :parameters

  def prepare_3d_chart_content(data)
    output = "<script>(function() { \nvar i=" + parameters["chart_id"] + ";"
    output += "\nvar data = " + data.to_json + ";" if data != nil
    output += "\nthreeD_main(i, \"" + parameters["notation"] +"\",\"" + parameters["param_x"] + "\", \"" + parameters["param_y"] + "\", \"" + parameters["param_z"] + "\", data);"
    output += "\n})();</script>"
    output

  end



  def handler
    if parameters["id"] && parameters["chart_id"] && parameters["param_x"] && parameters["param_y"] && parameters["param_z"]
      data = get3d(parameters["param_x"], parameters["param_y"], parameters["param_z"])
      object = prepare_3d_chart_content(data)
      object
    else
      error("Request parameters missing")
    end
  end



  def get3d(param_x, param_y, param_z)
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
    argument_ids.each do |arg_name|
      mins[arg_name] = params[arg_name].min
      maxes[arg_name] = params[arg_name].max
    end

    data = []

    #counter = Array.new(simulation_runs.size, &:next)
    #simulation_runs.size
    counter  = 0
    if argument_ids.index(param_x)
      simulation_runs.map do |data_sim|

        data[counter] = [data_sim[:arguments][param_x]]
        counter+=1
      end
    else
      simulation_runs.map do |data_sim|

        data[counter] = [data_sim[:result][param_x]]
        counter+=1

      end
    end


    counter  = 0
    if argument_ids.index(param_y)
      simulation_runs.map do |data_sim|

        data[counter].push(data_sim[:arguments][param_y])
        counter+=1
      end
    else
      simulation_runs.map do |data_sim|

        data[counter].push(data_sim[:result][param_y])
        counter+=1

      end
    end
    counter  = 0
    if argument_ids.index(param_z)
      simulation_runs.map do |data_sim|

        data[counter].push(data_sim[:arguments][param_z])
        counter+=1
      end
    else
      simulation_runs.map do |data_sim|

        data[counter].push(data_sim[:result][param_z])
        counter+=1

      end
    end
    data
  end


end