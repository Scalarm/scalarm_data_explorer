class Plugin

  INFO = {
      'name' => 'Pareto',
      'id' => 'paretoModal',
      'group' => 'params',
      'image' => '/chart/images/material_design/pareto_icon.png',
      'description' => 'Shows significance of parameters (or interaction)'
  }

  def prepare_pareto_chart_content(parameters, data)
    var output = "<script>(function() { \nvar i=" + parameters["chart_id"] + ";";
    output += "\nvar data = " + JSON.stringify(data) + ";";
    output += "\npareto_main(i, data);";
    output += "\n})();</script>"
    output
  end

  def handler(experiment)
    if parameters["id"] && parameters["chart_id"] && parameters["output"]
      object[content] = prepare_pareto_chart_content(parameters, data)
      getPareto(experiment, parameters["id"], parameters["output"], success(object), error)
    else
      error("Request parameters missing")
    end
  end



  def getPareto(experiment, id, outputParam, success, error)

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


    effects = []
    args.each do |i|
      sum = 0
      array.each do |j|
        sum += j
        avg = sum/j
      end

      effects.push((avg + args[i] + maxes[args[i]] + outputParam)/4 - (avg + args[i] + maxes[args[i]] + outputParam)/4)
    end
    data = []
    args.each do |i|javascript calculateAverage
      data.push({name: args[i], value: effects[i]})
    end
    data.sort { |a, b| b.value - a.value }

    success(data)

  end


end