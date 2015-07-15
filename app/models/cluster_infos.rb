require 'rinruby'
require 'benchmark'
class ClusterInfos

  attr_accessor :simulations_index
  attr_accessor :experiment


  def initialize(experiment, simulations_index)

    #getting data
    @experiment = experiment
    @simulations_index = simulations_index #[214,51,219,123,98]

  end

  def evaluate
    header, result_data = create_result_csv
    datas =  statistics(header,result_data)
    datas
  end
  def statistics(header,result_data)
    datas = {}

    for counter in 0..(header.count()-1)
      #assign table once before executing
      R.assign(header[counter],result_data.map{|row| row[counter]})
      datas[header[counter]] = result_data.map{|row| row[counter]}

    end
    R.eval ("require ('e1071', quietly=TRUE)")
    hash = {}

    hash[:skewness] = evaluate_r_function(header, "skewness")
    hash[:kurtosis] = evaluate_r_function(header, "kurtosis")
    hash[:inter_quartile_ranges] = evaluate_r_function(header, "IQR")
    hash[:means] = evaluate_r_function(header, "mean")
    hash[:variances] = evaluate_r_function(header, "var")
    hash[:standard_deviation] = evaluate_r_function(header, "sd")
    hash[:lower_quartiles] = evaluate_r_quantile(header,2)
    hash[:medians] = evaluate_r_quantile(header,3)
    hash[:upper_quartiles] = evaluate_r_quantile(header,4)
    hash[:arguments_ranges] = arguments_ranges(header, datas)

    hash
  end

  def evaluate_r_function(header, function)
    hash = {}
    header.each do |arg|

      R.eval ("x <- #{function}(#{arg})")
      value = R.pull "x"
      hash[arg] = value
    end
    hash
  end

  def evaluate_r_quantile(header, number)
    hash = {}
    header.each do |arg|

      R.eval ("x <- quantile(#{arg})[[#{number}]]")
      value = R.pull "x"
      hash[arg] = value
    end
    hash
  end

  def arguments_ranges(header, result_data)
    hash = {}
    header.each do |arg|
      param_data = result_data[arg]
      hash[arg] = [param_data.min, param_data.max, param_data.max - param_data.min]
    end
    hash
  end

  def moe_names
    moe_name_set = []
    limit = @experiment.size > 1000 ? @experiment.size / 2 : @experiment.size
    @experiment.simulation_runs.where({ is_done: true }, { fields: %w(result), limit: limit }).each do |simulation_run|
      moe_name_set += simulation_run.result.keys.to_a
    end

    moe_name_set.uniq
  end

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

  def create_result_csv(with_index=false, with_params=true, with_moes=true)
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


  def create_header(moes, with_index, with_moes, with_params)

    if with_params
      all_parameters = parameters_names.uniq.flatten
    end
    header = []
   # header += ['simulation_index'] if with_index
    header += all_parameters if with_params
    header += moes if with_moes
    header
  end

end