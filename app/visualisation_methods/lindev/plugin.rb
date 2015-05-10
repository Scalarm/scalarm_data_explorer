class Plugin

  INFO = {
      'name' => 'Line chart',
      'id' => 'lindevModal',
      'group' => 'basic',
      'image' => '/chart/images/material_design/lindev_icon.png',
      'description' => 'Line chart with standard deviation'
  }

  def prepare_lindev_chart_content(parameters, data)
             var output = "<script>(function() { \nvar i=" + parameters["chart_id"] + ";";
             output += "\nvar data = " + JSON.stringify(data) + ";";
             output += "\nlindev_main(i, \"" + parameters["param1"] + "\", \"" + parameters["param2"] + "\", data);";
             output += "\n})();</script>"
             return output
  end


  def getter(param, args)
    (args.indexOf(param) < 0) ? return result[param] : return arguments[param]
  end


  def getLineDev (experiment, id, param1, param2, success)
    experiment = Scalarm::Database::Model::Experiment.new({})
    array = experiment.simulation_runs

    # ...


    # dane id array args mins maxes
    get_param1 = getter(param1, args)
    get_param2 = getter(param2, args)
    grouped_by_param1 = {}

    if grouped_by_param1.include? get_param1
      grouped_by_param1[get_param1].push(get_param2)
    else grouped_by_param1[get_param1] = get_param2
    end

    values = []
    grouped_by_param1.each do |index|
      sum = grouped_by_param1[index].reduce(a+b, 0)#reduce?
      mean = sum/grouped_by_param1[index].length
      values.push(index, mean)
    end
    values = values.sort(a[0]-b[0]);#sort
    with_stddev = []
    grouped_by_param1.each do |index|
      sum = grouped_by_param1[index].reduce(a+b, 0)
      mean = sum/grouped_by_param1[index].length
      partial_sd = 0
      grouped_by_param1[index].each do |i|
        partial_sd += **(grouped_by_param1[index][i]-mean)
      end
      sd = Math.sqrt(partial_sd/grouped_by_param1[index].length)
      with_stddev.push([index, mean-sd, mean+sd])
    end
    with_stddev = with_stddev.sort(a[0] - b[0])

    success([values, with_stddev])
  end







  def handler(experiment)
    # dane parameters success error
    if parameters["id"] && parameters["param1"] && parameters["param2"]


      if parameters["type"] == "data"
        object = content[JSON.stringify(data)]
        success(object)
      elsif parameters["chart_id"]
        object.content = prepare_lindev_chart_content(parameters, data)
        object.input_parameters = retreived_parameters["parameters"]
        object.moes = retreived_parameters["result"]

      else
        error("Request parameters missing: 'chart_id'");

      end
      getLineDev(experiment, arameters["id"], parameters["param1"], parameters["param2"], success([values, with_stddev]))
      error("Request parameters missing: 'id', 'param1' or 'param2'");
    end
  end

end
