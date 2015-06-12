class Lindev
  attr_accessor :experiment
  attr_accessor :parameters

  INFO = {
      'name' => 'Line chart',
      'id' => 'lindevModal',
      'group' => 'basic',
      'image' => '/chart/images/material_design/lindev_icon.png',
      'description' => 'Line chart with standard deviation'
  }

  def prepare_lindev_chart_content(parameters, data)
             output = "<script>(function() { \nvar i=" + parameters["chart_id"] + ";"
             #output += "\nvar data = " + JSON.stringify(data) + ";"
             output += "\nvar data = " + ActiveSupport::JSON.decode(data) + ";" if data != nil

             output += "\nlindev_main(i, \"" + parameters["param1"] + "\", \"" + parameters["param2"] + "\", data);"
             output += "\n})();</script>"

             return output


  end




  def getter(param, args)
    (args.indexOf(param) < 0) ? result[param] : arguments[param]
  end


  def getLineDev (experiment, id, param1, param2)
    #dao.getData(id, function(array, args, mins, maxes){

    ## TODO
    experiment = Scalarm::Database::Model::Experiment.new({})
    array = experiment.simulation_runs.to_a

    # if array.length == 0
    #   error("No such experiment or no runs done")
    # end

    args = array.first.arguments.split(',')
    values = array.values.split(',')

    array = array.map do |data|
      values = data.values.split(',')
      new_args = {}
      args.each do |i|
        new_args[args[i]] = values[i].to_f
      end
      data.arguments = new_args
      remove_instance_variable(data.values)
      data.result.each do |key|
        data.result[key] = Float(data.result[key]) unless data.result[key].is_a? Float
      end
      data
    end

    mins = []
    maxes = []
    args.each do |i|
      mins[args[i]] = min { |array, args|}
      maxes[args[i]] = max { |array, args|}
    end

    get_param1 = getter(param1, args)
    get_param2 = getter(param2, args)
    grouped_by_param1 = {}
      array.map do |obj|
        if grouped_by_param1.include? get_param1(obj)
          grouped_by_param1[get_param1(obj)].push(get_param2(obj))
        else grouped_by_param1[get_param1(obj)] = get_param2(obj)
        end
      end
    array
    #
    # values = []
    # grouped_by_param1.each do |index|
    #   sum = grouped_by_param1[index].reduce(1, :+)
    #   mean = sum/grouped_by_param1[index].length
    #   values.push(Float(index, mean))
    # end
    # values = values.sort_by{|e| e}
    # with_stddev = []
    # grouped_by_param1.each do |index|
    #   sum = grouped_by_param1[index].reduce(1, :+)
    #   mean = sum/grouped_by_param1[index].length
    #   partial_sd = 0
    #   grouped_by_param1[index].each do |i|
    #     partial_sd += **(grouped_by_param1[index][i]-mean)
    #   end
    #   sd = Math.sqrt(partial_sd/grouped_by_param1[index].length)
    #   with_stddev.push(Float([index, mean-sd, mean+sd]))
    # end
    # with_stddev = with_stddev.sort_by{|e| e}
    #
    # success([values, with_stddev])
    rescue
      nil
  end







  def handler
    # dane parameters success error
    if parameters["id"] && parameters["param1"] && parameters["param2"]

      object = {}
      data = getLineDev(experiment, parameters["id"], parameters["param1"], parameters["param2"])
      if parameters["type"] == "data"

        object = content[JSON.stringify(data)]
      elsif parameters["chart_id"]
        object[:content] = prepare_lindev_chart_content(parameters, data)
        #object[:input_parameters] = retreived_parameters["parameters"]
        #object[:moes] = retreived_parameters["result"]

      else
        error("Request parameters missing: 'chart_id'");

      end
      getLineDev(experiment, parameters["id"], parameters["param1"], parameters["param2"])

    end
  end

end
