require 'rinruby'

class ClusterInfos
  attr_accessor :simulations_index
  attr_accessor :experiment

  ##
  # init class and R package
  def initialize(experiment, simulations_index)
    R.eval ("require ('e1071', quietly=TRUE)")

    #getting data
    @experiment = experiment
    @simulations_index = simulations_index

  end

  ##
  # function to get all data about simulations
  def evaluate
    header, result_data = create_data_result
    datas =  statistics(header,result_data)
    datas
  end

  ##
  # main function which collect all data and return it as hash
  def statistics(header,result_data)
    datas = {}

    for counter in 0..(header.count()-1)
      #assign table once before executing
      R.assign(header[counter],result_data.map{|row| row[counter]})
      datas[header[counter]] = result_data.map{|row| row[counter]}

    end
    hash = {}

    hash[:skewness] = evaluate_r_function(header, "skewness")
    hash[:kurtosis] = evaluate_r_function(header, "kurtosis")


    # in Ruby gem these methods are faster
    hash[:means] = calculate_function(header, datas,"mean")
    # evaluate_r_function(header, "mean")
    hash[:medians] = calculate_function(header, datas,"median")
    # evaluate_r_quantile(header,3)

    # differences with variance and standard_deviation results between R and Ruby method for now stay Ruby function
    hash[:variances] = calculate_function(header, datas,"variance")
    # evaluate_r_function(header, "var")
    hash[:standard_deviation] = calculate_function(header, datas,"standard_deviation")
    # evaluate_r_function(header, "sd")

    hash[:lower_quartiles] = calculate_function(header, datas,"q1")
    # evaluate_r_quantile(header,2)
    hash[:upper_quartiles] = calculate_function(header, datas,"q3")
    # evaluate_r_quantile(header,4)
    iqr = {}
    header.each do |name|
      iqr[name]= hash[:upper_quartiles][name].to_f- hash[:lower_quartiles][name].to_f

    end
    hash[:inter_quartile_ranges] = iqr
    # evaluate_r_function(header, "IQR")
    hash[:arguments_ranges] = arguments_ranges(header, datas)

    hash
  end


  ##
  # calculate by ruby descriptive statistics gem
  # available functions:
  # 1. number
  # 2 .sum
  # 3. mean
  # 4. median
  # 5. mode
  # 6. variance
  # 7. standard Deviation
  # 8. percentile
  # 9. percentile Rank
  # 10. descriptive statistics
  # 11. quartiles

  def calculate_function(header, datas, function)
    hash = {}
    header.each do |arg|
      param_data = datas[arg]
      case function
        when "mean"
          hash[arg] = param_data.mean
        when "variance"
          hash[arg] = param_data.variance
        when "median"
          hash[arg] = param_data.median
        when "standard_deviation"
          hash[arg] = param_data.standard_deviation
        when "q1"
          hash[arg] = param_data.percentile(25)
        when "q3"
          hash[arg] = param_data.percentile(75)
      end

    end
    hash

  end

  ##
  # executing function in R by RinRuby gem
  # passing array of arguments (in,out) and name of function
  def evaluate_r_function(header, function)
    hash = {}
    header.each do |arg|

      R.eval ("x <- #{function}(#{arg})")
      value = R.pull "x"
      hash[arg] = value
    end
    hash
  end

  ##
  # calculating in R quantile
  def evaluate_r_quantile(header, number)
    hash = {}
    header.each do |arg|

      R.eval ("x <- quantile(#{arg})[[#{number}]]")
      value = R.pull "x"
      hash[arg] = value
    end
    hash
  end

  ##
  # creating table of result data ranges
  def arguments_ranges(header, result_data)
    hash = {}
    header.each do |arg|
      param_data = result_data[arg]
      param_data = param_data.map{|param| param.to_f}
      hash[arg] = [param_data.min, param_data.max, param_data.max - param_data.min]
      Rails.logger.debug(hash)
    end
    Rails.logger.debug(hash)
    hash
  end

  ##
  # get moes (results) names as an array
  def moe_names
    moe_name_set = []
    limit = @experiment.size > 1000 ? @experiment.size / 2 : @experiment.size
    @experiment.simulation_runs.where({ is_done: true }, { fields: %w(result), limit: limit }).each do |simulation_run|
      moe_name_set += simulation_run.result.keys.to_a
    end

    moe_name_set.uniq
  end

  ##
  # get input paramaters names as an array
  def parameters_names
    parameters_names = []

    @experiment.experiment_input.each do |entity_group|
      entity_group['entities'].each do |entity|
        entity['parameters'].each do |parameter|
          parameters_names << @experiment.get_parameter_ids unless parameter.include?('in_doe') and parameter['in_doe'] == true
        end
      end
    end

    parameters_names
  end


  ##
  # no simulation index in header and with input and output paramameters
  def create_data_result(with_index=false, with_params=true, with_moes=true)
    moes = moe_names
    if with_params
      all_parameters = parameters_names.uniq.flatten
    end
    data_array=[]
    header = []
    header.push('simulation_index') if with_index
    all_parameters.each do |value|
      header.push(value)
    end

    moes.each do |moe|
      header.push(moe)
    end if with_moes

    query_fields = {_id: 0}
    query_fields[:index] = 1 if with_index
    query_fields[:values] = 1 if with_params
    query_fields[:result] = 1 if with_moes

    @experiment.simulation_runs.where(
        {is_done: true, is_error: {'$exists' => false}, 'index' => {'$in' => @simulations_index }},
        {fields: query_fields}
    ).each do |simulation_run|
      line = []
      line.push(simulation_run.index) if with_index
      values = simulation_run.values.split(',')if with_params

      values.each do |value|
        line.push(value.to_f)
      end
      moes.map { |moe_name|
        line.push(simulation_run.result[moe_name] || '') } if with_moes
      data_array.push(line)

    end

    return header, data_array
  end

end