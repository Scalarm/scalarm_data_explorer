class Boxplot
  attr_accessor :experiment
  attr_accessor :parameters


  def handler
    if parameters['id'] && parameters['param_x'].to_s && parameters['param_y'].to_s
      object = {}
      data = get_boxplot_data(experiment, parameters['param_x'].to_s, parameters['param_y'].to_s)
      if parameters['type'] == 'data'
        object = content[JSON.stringify(data)]
      elsif parameters['chart_id']
        object = prepare_boxplot_chart_content(data)
      else
        raise("Request parameters missing: 'chart_id'");
      end
      object
    end
  end


  ##
  # return script tag with function draws box-plot
  def prepare_boxplot_chart_content(data)
    output = "<script>(function() { \nvar i=" + parameters['chart_id'] + ';'
    output += "\nvar data = " + data[:data].to_json + ';' if data[:data] != nil
    output += "\nvar categories = " + data[:categories].to_json + ';' if data[:categories] != nil
    output += "\nvar outliers = " + data[:outliers].to_json + ';' if data[:outliers] != nil
    output += "\nvar mean = " + data[:mean].to_json + ';' if data[:mean] != nil
    output += "\nboxplot_main(i, \"" + parameters['param_x'] + "\", \"" + parameters['param_y'] + "\", data, categories, outliers, mean);"
    output += "\n})();</script>"
    output
  end


  ##
  # create data needed to drow plot, return hash {:data => data, :categories => [], :outliers => [], :mean => x}
  # data - array of [whisker_bottom, lower_quartile, median, upper_quartile, whisker_up]
  # categories - values of param_x (max 10)
  # outliers - array with outliners (points outside whiskers), for (x,y): x is box number, y is outliner value
  # mean - mean of param_y
  def get_boxplot_data (experiment, param_x, param_y)
    filter = {is_done: true, is_error: {'$exists'=> false}}
    simulation_runs = experiment.simulation_runs.where(filter).to_a

    if simulation_runs.length == 0
      raise('No such experiment or no runs done')
    end

    # get input parameter names
    argument_ids = simulation_runs.first.arguments.split(',')

    simulation_runs = simulation_runs.map do |simulation_run|
      get_parameters(simulation_run, argument_ids)
    end

    #filling grouped_by_param_x with correct data
    grouped_by_param_x = grouping_by_parameter(argument_ids, {}, param_x, param_y, simulation_runs)

    data = []
    outliers = []
    moes = []
    grouped_by_param_x.each_with_index do |(key, value), index|
      moes += value
      stats = get_statictics(value)
      data.push(stats.values)
      outliers = outliers + find_outliers(value, index, stats['q1'], stats['q3'])
    end
    {:data => data, :categories => grouped_by_param_x.keys, :outliers => outliers, :mean => moes.mean}
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
  # get array of values and raturn array: [whisker_bottom, lower_quartile, median, upper_quartile, whisker_up]
  def get_statictics(values_in_category)
    stats = {}
    q1 = values_in_category.percentile(25)
    q3 = values_in_category.percentile(75)
    iqr = q3 - q1
    stats['whisker_bottom'] = q1 - 1.5 * iqr
    stats['q1'] = q1
    stats['med'] = values_in_category.median
    stats['q3'] = q3
    stats['whisker_upper'] = q3 + 1.5 * iqr
    stats
  end


  ##
  # return array with outliners (points outside whiskers), x is box number
  def find_outliers(values, index, q1, q3)
    outliers = []
    iqr = q3 - q1
    values.each do |value|
      if value < q1 - 1.5 * iqr || value > q3 + 1.5 * iqr
        outliers.push([index.to_i, value])
      end
    end
    outliers
  end
end