class Pareto

  attr_accessor :experiment
  attr_accessor :parameters

  def prepare_pareto_chart_content(data)
    output = "<script>(function() { \nvar i=" + parameters["chart_id"] + ";"
    output += "\nvar data = " + data.to_json + ";" if data != nil
    output += "\npareto_main(i, data);"
    output += "\n})();</script>"
    output
  end

  def handler()
    if parameters["id"] && parameters["chart_id"] && parameters["output"]
      data = get_pareto_data
      object = prepare_pareto_chart_content(data)
      object
    else
      raise("Request parameters missing")
    end

  end

  def get_pareto_data


    simulation_runs = experiment.simulation_runs.to_a
    if simulation_runs.length == 0
      raise("No such experiment or no runs done")
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



    #preparing Chart content
    data =[]
    argument_ids.each do |arg_name|
      local_max =  maxes[arg_name]
      local_min = mins[arg_name]
      count_min = params[arg_name].count(local_min)
      count_max = params[arg_name].count(local_max)
      sum_min =0
      sum_max =0
      simulation_runs.map do |datas|
        if datas[:arguments][arg_name] ==local_max
          sum_max+=datas[:result].values.reduce(:+)
          end

        if datas[:arguments][arg_name] ==local_min
          sum_min+=datas[:result].values.reduce(:+)
        end

      end
      data.push({ name: arg_name, value: ((sum_max/count_max)-(sum_min/count_min)).to_f.abs})
    end
    data


  end


end