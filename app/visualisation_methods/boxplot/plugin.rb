class Boxplot
  attr_accessor :experiment
  attr_accessor :parameters


  def handler
    if parameters["id"] && parameters["param_x"].to_s && parameters["param_y"].to_s

      object = {}
      data = get_boxplot_data(experiment, parameters["param_x"].to_s, parameters["param_y"].to_s)
      if parameters["type"] == "data"
        object = content[JSON.stringify(data)]
      elsif parameters["chart_id"]
        object = prepare_boxplot_chart_content(data)
      else
        raise("Request parameters missing: 'chart_id'");
      end
      object
    end
  end


  def prepare_boxplot_chart_content(data)
    output = "<script>(function() { \nvar i=" + parameters["chart_id"] + ";"
    output += "\nvar data = " + data[:data].to_json + ";" if data != nil
    output += "\nvar categories = " + data[:categories].to_json + ";" if data != nil
    output += "\nvar outliers = " + data[:outliers].to_json + ";" if data != nil
    output += "\nboxplot_main(i, \"" + parameters["param_x"] + "\", \"" + parameters["param_y"] + "\", data, categories, outliers);"
    output += "\n})();</script>"
    output
  end

  def get_boxplot_data (experiment, param_x, param_y)
    simulation_runs = experiment.simulation_runs.to_a

    if simulation_runs.length == 0
      raise('No such experiment or no runs done')
    end

    # get input parameter names
    argument_ids = simulation_runs.first.arguments.split(',')

    simulation_runs = simulation_runs.map do |simulation_run|
      get_parameters(simulation_run, argument_ids)
    end

    #filling grouped_by_param_x with correct data
    # grouped_by_param_x = grouping_by_parameter(argument_ids, {}, param_x, param_y, simulation_runs)
    grouped_by_param_x =  {1.0=>[1.0, 7.0, 5.0, 20.0], 2.0=>[10.0, 2.0, 14.0, 40.0]}


    data = []
    outliers = []
    grouped_by_param_x.each do |key, value|
      stats = get_statictics(value)
      data.push(stats.values)
      outliers = outliers + find_outliners(value, key, stats['q1'], stats['q3'])
    end


    Rails.logger.debug(grouped_by_param_x)
    Rails.logger.debug(data)
    Rails.logger.debug(outliers)

    {:data => data, :categories => grouped_by_param_x.keys, :outliners => outliers}
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
  # get array of values and raturn array: [min, lower_quartile, median, upper_quartile, max]
  def get_statictics(values_in_category)
    stats = {}
    stats['min'] = values_in_category.min
    stats['q1'] = values_in_category.percentile(25)
    stats['med'] = values_in_category.median
    stats['q3'] = values_in_category.percentile(75)
    stats['max'] = values_in_category.max
    # iqr = stats[:q3] - stats[:q1]
    # stats[:interval] = [stats[:q1] - 1.5 * iqr, stats[:q3] - 1.5 * iqr]
    Rails.logger.debug(stats)
    stats
  end

  def find_outliners(values, key, q1, q3)
    outliers = []
    iqr = q3 - q1
    values.each do |value|
      if value < q1 - 1.5 * iqr || value > q3 + 1.5 * iqr
        outliers.push([key, value])
      end
    end
    outliers
    # jeśli to nie jest puste to trzeba znowu policzyć statystyki??
  end

end