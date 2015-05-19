class Plugin

  INFO = {
      'name' => 'Plugin',
      'id' => 'interactionModal',
      'group' => 'params',
      'image' => '/chart/images/material_design/interaction_icon.png',
      'description' => 'Shows interaction between 2 input parameters'
  }

  def prepare_interaction_chart_content(parameters, data)
    output = "<script>(function() { \nvar i=" + parameters["chart_id"] + ";";
    output += "\nvar data = " + JSON.stringify(data) + ";"
    output += "\ninteraction_main(i, \"" + parameters["param1"] + "\", \"" + parameters["param2"] + "\", data);";
    output += "\n})();</script>";
    output

  end


  def handler(experiment)
    # dane parameters success error
    if parameters["id"] && parameters["chart_id"] && parameters["param1"] && parameters["param2"] && parameters["output"]
      object = content[prepare_interaction_chart_content(parameters, data)]
      getInteraction(experiment, id, param1, param2, outputParam, success(object), error)
    else
      error('Request parameters missing');
    end
  end


  def getInteraction(experiment, id, param1, param2, outputParam, success, error)
    experiment = Scalarm::Database::Model::Experiment.new({})
    array = experiment.simulation_runs.to_a
    #TODO nil check
    array.first.arguments.split(',')

    # ...

    # dane id array args mins maxes
    low_low = array.select(param1 == mins[param1]).select(param2 == mins[param2])[0]
    low_high = array.select(param1 == mins[param1]).select(param2 == maxes[param2])[0]
    high_low = array.select(param1 == maxes[param1]).select(param2 == mins[param2])[0]
    high_high = array.select(param1 == maxes[param1]).select(param2 == maxes[param2])[0]

    if (!low_low && low_high && high_low && high_high)
      error('Not enough data in database!')
      return
    else
      result = []

      result.push(low_low.result[outputParam],
                  low_high.result[outputParam],
                  high_low.result[outputParam],
                  high_high.result[outputParam])
      data = {}
      data[param1] = {domain: [mins[param1], maxes[param1]]}
      data[param2] = {domain: [mins[param1], maxes[param1]]}

    end

                             #data.effects = result;
                             #//console.log(data);
                             #success(data);
                             #}
                             #}, error);
                             #};

  end

end


