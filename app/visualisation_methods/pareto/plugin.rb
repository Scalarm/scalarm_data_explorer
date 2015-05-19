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
    #TODO nil check
    array.first.arguments.split(',')
    effects = []
    args.each do |i|
      effects.push
    end
    data = []
    args.each do |i|
      data.push({name: args[i], value: effects[i]})
    end
    data.sort(b.value-a.value)
    success(data)

  end


end