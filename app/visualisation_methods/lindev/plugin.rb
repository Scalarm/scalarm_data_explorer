class Lindev
  attr_accessor :experiment
  attr_accessor :parameters


  def handler
    if parameters["id"] && parameters["param_x"] && parameters["param_y"]

      object = {}
      data = get_line_dev_data(experiment, parameters["id"], parameters["param_x"], parameters["param_y"])
      if parameters["type"] == "data"
        object = content[JSON.stringify(data)]
      elsif parameters["chart_id"]
        object = prepare_lindev_chart_content(data)
      else
        error("Request parameters missing: 'chart_id'");
      end
      object

    end
  end


  def prepare_lindev_chart_content(data)
    output = "<script>(function() { \nvar i=" + parameters["chart_id"] + ";"
    output += "\nvar data = " + data.to_json + ";" if data != nil
    output += "\nlindev_main(i, \"" + parameters["notationx"] + "\", \"" +  parameters["notationy"]+  "\", \"" + parameters["param_x"] + "\", \"" + parameters["param_y"] + "\", data);"
    output += "\n})();</script>"

    output


  end


  # TODO: documentation - what this method does? change name
  def get_line_dev_data (experiment, id, param_x, param_y)

    simulation_runs = experiment.simulation_runs.to_a

    if simulation_runs.length == 0
      error("No such experiment or no runs done")
    end

    argument_ids = simulation_runs.first.arguments.split(',')

    simulation_runs = simulation_runs.map do |data|
      obj ={}

      values = data.values.split(',')
      new_args = {}
      argument_ids.each_with_index do |arg_name, index|
        new_args[arg_name] = values[index].to_f
      end

      obj[:arguments] = new_args
      obj[:result] = {}
      #remove_instance_variable(data.values)
      unless data.result.nil?
        data.result.each do |key, value|
          obj[:result][key] = value.to_f rescue 0.0
        end
      end

      obj
    end

    grouped_by_param_x = {}

    #filling grouped_by_param_x with correct data
    grouping_by_parameter(argument_ids, grouped_by_param_x, param_x, param_y, simulation_runs)
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
    #creating result table -> mean values
  #  values = calculate_mean_values(grouped_by_param_x, values)

  #  with_stddev = []
    #creating result table -> standard deviation values
  #  with_stddev = calculate_standard_deviation(grouped_by_param_x, with_stddev)

    [values, with_stddev]

  end


  def calculate_standard_deviation(grouped_by_param_x, with_stddev)
    grouped_by_param_x.each do |key, value|
      sum = value.kind_of?(Array) ? value.inject(0){ |accum, i| accum + i }: value
      mean = value.kind_of?(Array) ? sum / value.length.to_f : sum
      partial_sd = 0
      if value.kind_of?(Array)
        value.each do |i|
          partial_sd += (i-mean)**2
        end
      else
        partial_sd = (value-mean)**2
      end
      sd = value.kind_of?(Array) ? Math.sqrt(partial_sd/value.length-1).to_f : Math.sqrt(partial_sd).to_f
      with_stddev.push([key.to_f, (mean-sd).to_f, (mean+sd).to_f])
    end
    with_stddev = with_stddev.sort_by { |e| e }

    with_stddev
  end


  def calculate_mean_values(grouped_by_param_x, values)
    grouped_by_param_x.each do |key, value|
      sum = value.kind_of?(Array) ? value.reduce(:+) : value
      mean = value.kind_of?(Array) ? sum/value.length : sum
      values.push([key.to_f, mean])

    end
    values = values.sort_by{|e| e}

    values
  end


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
  end




end