class Pareto

  attr_accessor :experiment
  attr_accessor :parameters
  include Scalarm::ServiceCore::ParameterValidation

  ##
  # create data for chart and <script> which is rendered in ChartInstancesController
  def handler()
    if parameters["id"] && parameters['chart_id'] && parameters["output"].to_s
      data = get_pareto_data(parameters["output"].to_s)
      object = prepare_pareto_chart_content(data)
      object
    else
      raise SecurityError.new('Request parameters missing')
    end
  end

  ##
  # create <script>> which is load on page
  def prepare_pareto_chart_content(data)
    output = "<script>(function() { \nvar i=" + parameters["chart_id"] + ";"
    output += "\nvar data = " + data.to_json + ";" if data != nil
    output += "\npareto_main(i, data);"
    output += "\n})();</script>"
    output
  end

  ##
  # prepare data for draw function
  #
  # Details:
  # In first step for each input parameter search it minimum and maximum value
  # next step is to count occurances for these values and sum all output values for given output parameter(moes)
  # Finally calculate absolute value of subtraction of average min and max value for parameter
  def get_pareto_data(moes)
    simulation_runs = experiment.simulation_runs.to_a
    if simulation_runs.length == 0
      raise SecurityError.new('No such experiment or no simulation runs done')
    else
      argument_ids = simulation_runs.first.arguments.split(',')
      params = {}
      simulation_runs = simulation_runs.map do |data|
        get_parameters(data, argument_ids, params, moes)
      end
      mins = {}
      maxes = {}

      argument_ids.each do |arg_name|
        mins[arg_name] = params[arg_name].min
        maxes[arg_name] = params[arg_name].max
      end

      #preparing Chart content
      data = []
      argument_ids.each do |arg_name|
        get_chart_content_for_argument(arg_name, data, maxes, mins, params, simulation_runs)
      end
      data
    end
  end


  ##
  # get input and output parameters for simulation run, return hash: {:arguments=>{"parameter1"=>1.0, "parameter2"=>2.0}, :result=>{"product"=>3.0}}
  def get_parameters(data, argument_ids, params, moes)
    obj = {}
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
        if moes.eql? key
          obj[:result] = value.to_f rescue 0.0
        end
      end
    end
    obj
  end


  ##
  # return {:name=>"parameter1", :value=>3.0}
  def get_chart_content_for_argument(arg_name, data, maxes, mins, params, simulation_runs)
    local_max = maxes[arg_name]
    local_min = mins[arg_name]
    count_min = params[arg_name].count(local_min)
    count_max = params[arg_name].count(local_max)
    sum_min = 0
    sum_max = 0
    simulation_runs.map do |datas|
      if datas[:arguments][arg_name] == local_max
        sum_max += datas[:result]
      end

      if datas[:arguments][arg_name] == local_min
        sum_min += datas[:result]
      end
    end
    data.push({ name: arg_name, value: ((sum_max/count_max)-(sum_min/count_min)).to_f.abs})
  end
end

  
