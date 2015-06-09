class ThreeD

  INFO = {
      'name' => '3D chart',
      'id' => 'threeDModal',
      'group' => 'basic',
      'image' => '/chart/images/material_design/3dchart_icon.png',
      'description' => '3D charts - scatter plot'
  }

  def prepare_3d_chart_content(parameters, data)
    output = "<script>(function() { \nvar i=" + parameters["chart_id"] + ";"
    output += "\nvar data = " + JSON.stringify(data) + ";"
    output += "\nthreeD_main(i, \"" + parameters["param1"] + "\", \"" + parameters["param2"] + "\", \"" + parameters["param3"] + "\", data);"
    output += "\n})();</script>"
    output

  end



  def handler(experiment)
    if parameters["id"] && parameters["chart_id"] && parameters["param1"] && parameters["param2"] && parameters["param3"]
      object = {}
      object.content = prepare_3d_chart_content(parameters, data)
      get3d(experiment, parameters["id"], parameters["param1"], parameters["param2"], parameters["param3"], success(object))
    else
      error("Request parameters missing")
    end
  end



  def get3d(experiment, id, param1, param2, param3, success)
    #dao.getData(id, function(array, args, mins, maxes){

    experiment = Scalarm::Database::Model::Experiment.new({})
    array = experiment.simulation_runs.to_a
    if array.length == 0
      error("No such experiment or no runs done")
    end

    args = array.first.arguments.split(',')


    array = array.map do |data|
      values = data.values.split(',')
      new_args = {}
      args.each do |i|
        new_args[args[i]] = Float(values[i])
      end
      data.arguments = new_args
      remove_instance_variable(data.values)
      data.result.each do |key|
        data.result[key] = Float(data.result[key]) unless data.result[key].is_a? Float
      end
    end

    mins = []
    maxes = []
    args.each do |i|
      mins[args[i]] = min { |array, args|}
      maxes[args[i]] = max { |array, args|}
    end

    data = []
    # TODO?
    #data.map { |Number.prototype.valueOf|}
    if args.index(param1) != -1
      data.each do |i|
        data[i] = array[i].arguments[param1]
      end
    else
      data.each do |i|
        data[i] = array[i].result[param1]
      end
    end
    if args.index(param2) != -1
      data.each do |i|
        data[i].pusch(array[i].arguments[param2])
      end
    else
      data.each do |i|
        data[i].push(array[i].result[param2])
      end
    end

    if args.index(param3) != -1
      data.each do |i|
        data[i].push(array[i].arguments[param3])
      end
    else
      data.each do |i|
        data[i].push(array[i].result[param3]);
      end
    end

  end





end