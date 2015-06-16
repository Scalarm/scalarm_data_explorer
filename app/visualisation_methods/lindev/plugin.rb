class Lindev
  attr_accessor :experiment
  attr_accessor :parameters



  def prepare_lindev_chart_content(data)
             output = "<script>(function() { \nvar i=" + parameters["chart_id"] + ";"
             #output += "\nvar data = " + JSON.stringify(data) + ";"
             output += "\nvar data = " + data.to_json + ";" if data != nil

             output += "\nwindow.lindev_main(i, \"" + parameters["param1"] + "\", \"" + parameters["param2"] + "\", data);"
             output += "\n})();</script>"

             output


  end




  def getter(param, args)
    (args.indexOf(param) < 0) ? result[param] : arguments[param]
  end


  ##
  # TODO: documentation - what this method does? change name
  def get_line_dev (experiment, id, param1, param2)
    #dao.getData(id, function(array, args, mins, maxes){

    ## TODO
    simulation_runs = experiment.simulation_runs.to_a

    # if array.length == 0
    #   error("No such experiment or no runs done")
    # end
    # Rails.logger.debug("################")
    # Rails.logger.debug(array)
    # Rails.logger.debug("################")
    # Rails.logger.debug(array.first)
    # Rails.logger.debug("################")
    # Rails.logger.debug(array.first.arguments)
    argument_ids = simulation_runs.first.arguments.split(',')
    #values = array.values.split(',')
    # Rails.logger.debug("################")
    # Rails.logger.debug(args)
   # Rails.logger.debug(values)

    simulation_runs = simulation_runs.map do |data|
      obj ={}

      values = data.values.split(',')
      new_args = {}
      argument_ids.each_with_index do |arg_name, index|
        new_args[arg_name] = values[index].to_f
      end
      # Rails.logger.debug("$$$$$$$$$$$$$$$$$")
      # Rails.logger.debug(new_args)
      #
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

    # Rails.logger.debug("################")
    # Rails.logger.debug(array)
    # mins = []
    # maxes = []
    # args.each do |i|
    #   mins[args[i]] = [array, args[i]].min
    #   maxes[args[i]] = [array, args[i]].max
    # end



   # get_param1 = getter(param1, args)
    #get_param2 = getter(param2, args)


    grouped_by_param1 = {}

    simulation_runs = simulation_runs.map do |obj|
      ## search for parameter value value in result or arguments
      param1_val = argument_ids.index(param1) ? obj[:arguments][param1] : obj[:result][param1]
      param2_val = argument_ids.index(param2) ? obj[:arguments][param2] : obj[:result][param2]

      if grouped_by_param1.include? param1_val
        grouped_by_param1[param1_val] = [param2_val]
      else
        grouped_by_param1[param1_val] = param2_val
      end
      obj
    end

    Rails.logger.debug(grouped_by_param1)


    values = []
    grouped_by_param1.each do |key,value|
      sum = value.kind_of?(Array) ? value.reduce(:+) : value
      mean = value.kind_of?(Array) ? sum/value.length : sum
      values.push([key.to_f, mean])
     end
    Rails.logger.debug(values)

    values = values.sort_by{|e| e}
    with_stddev = []
    grouped_by_param1.each do |key,value|
      sum = value.kind_of?(Array) ? value.reduce(:+) : value
      mean = value.kind_of?(Array)? sum/value.length : sum
      partial_sd = 0
      if value.kind_of?(Array)
        value.each do |i|
          partial_sd += (i-mean)**2
        end
      else
        partial_sd = (value-mean)**2
      end
      sd = value.kind_of?(Array)? Math.sqrt(partial_sd/value.length) : Math.sqrt(partial_sd)
      with_stddev.push([key.to_f, mean-sd, mean+sd])
    end
    with_stddev = with_stddev.sort_by{|e| e}

    [values, with_stddev]
    # success([values, with_stddev])
  end







  def handler
    # dane parameters success error
    if parameters["id"] && parameters["param1"] && parameters["param2"]

      object = {}
      data = get_line_dev(experiment, parameters["id"], parameters["param1"], parameters["param2"])
      if parameters["type"] == "data"

        object = content[JSON.stringify(data)]
      elsif parameters["chart_id"]
        object = prepare_lindev_chart_content(data)
        #object[:input_parameters] = retreived_parameters["parameters"]
        #object[:moes] = retreived_parameters["result"]

      else
        error("Request parameters missing: 'chart_id'");

      end
      object
      #getLineDev(experiment, parameters["id"], parameters["param1"], parameters["param2"])

    end
  end

end
