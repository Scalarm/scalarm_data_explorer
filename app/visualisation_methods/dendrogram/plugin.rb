class Dendrogram
  attr_accessor :experiment
  attr_accessor :parameters



  def prepare_dendrogram_chart_content(data)
    output = "<script>(function() { \nvar i=" + parameters["chart_id"] + ";"
    output += "\nvar data = " + data.to_json + ";" if data != nil
    output += "\nwindow.dendrogram_main(i, \"" + parameters["param1"] + "\", data);"
    output += "\n})();</script>"

    output
  end

  ##
  # TODO: documentation - what this method does? change name
  def get_data_for_dendrogram(experiment, id, param1)
    simulation_runs = experiment.simulation_runs.to_a


  end


  def handler
    if parameters["id"] && parameters["param1"]

      object = {}
      data = get_data_for_dendrogram(experiment, parameters["id"], parameters["param1"])
      if parameters["type"] == 'data'

        object = content[JSON.stringify(data)]
      elsif parameters["chart_id"]
        object = prepare_dendrogram_chart_content(data)
      else
        error("Request parameters missing: 'chart_id'");

      end
      object
    end
  end

end