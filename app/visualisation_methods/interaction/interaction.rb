class Interaction

  INFO = {
      'name' => 'Interaction',
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
    return output

  end


  def handler(dao)
    # dane parameters success error
    if parameters["id"] && parameters["chart_id"] && parameters["param1"] && parameters["param2"] && parameters["output"]
      object = content[prepare_interaction_chart_content(parameters, data)]
      getInteraction(dao, id, param1, param2, outputParam, success, error)
    else
      error('Request parameters missing');
    end
  end


  def getInteraction (dao, id, param1, param2, outputParam, success, error)
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
      data[param1] = max { |mins[param1]; maxes[param1]|} # domain
      data[param2] = max { |mins[param2]; maxes[param2]|}
    end

                             #data.effects = result;
                             #//console.log(data);
                             #success(data);
                             #}
                             #}, error);
                             #};

  end

end


