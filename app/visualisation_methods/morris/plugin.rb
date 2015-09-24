require 'json'

class Morris
  attr_accessor :experiment
  attr_accessor :parameters

  attr_reader :series_to_plot
  attr_reader :parameters_names
  attr_reader :sorted_parameters_names
  attr_reader :name_of_output
  attr_reader :series_names

  def prepare_morris_chart_content
    output = "<script>(function() { \nvar i=" + parameters["chart_id"] + ";"
    output += "\nvar sorted_parameters_names = " + @sorted_parameters_names.to_json + ";"
    output += "\nvar series_to_plot = " +  @series_to_plot.to_json + ";"
    output += "\nmorris_main(i, series_to_plot, sorted_parameters_names);"
    output += "\n})();</script>"
    output
  end

  ##
  # We assume that the result json have specific format:
  # '{
  #   "results":{
  #       "sensitivity_analysis_method":"morris",
  #       "moes":{
  #         "product2":{
  #           "parameter1":{
  #             "mean":3,
  #           "st.deviation ":2
  #         },
  #         "parameter2":{
  #           "mean":-1,
  #           "st.deviation ":4
  #         }
  #       },
  #       "moe1":{
  #         "parameter1":{
  #           "mean":5,
  #           "st.deviation ":1
  #         },
  #         "parameter2":{
  #           "mean":0,
  #           "st.deviation ":2
  #         }
  #       }
  #     }
  #  },
  #  "error_reason":"null"
  # }'
  def handler()
    if parameters["id"] && parameters["chart_id"] && parameters["output"]
      @name_of_output = parameters["output"]
      output_hash = @experiment.results

      if !output_hash.has_key?("results") ||
          output_hash["error_reason"] != "null" ||
          output_hash["results"]["sensitivity_analysis_method"] != 'morris'

          raise("Error appeared: "+ output_hash["error_reason"])
      end

      output_hash_results = output_hash['results']['moes'][@name_of_output]

      if !output_hash_results
        raise("No #{@name_of_output} in moes results from supervised experiment")
      end

      extract_categories_xAxis(output_hash_results)
      extract_categories_series(output_hash_results)
      sort_parameters_names(output_hash_results)
      extract_series(output_hash_results)
      object = prepare_morris_chart_content

      object
    else
      raise("Request parameters missing")
    end

  end

  def sort_parameters_names(output_hash_results)
    sorted_parameters_names = {}

    @parameters_names.each{|name_of_parameter|
      parameter_total_sum = 0.0
      output_hash_results[name_of_parameter].each_key{ |key|
        parameter_total_sum += output_hash_results[name_of_parameter][key]
      }
      sorted_parameters_names[name_of_parameter] = parameter_total_sum
    }

    @sorted_parameters_names = sorted_parameters_names.sort_by{ |k, v| v }.to_h.keys
  end

  def extract_series(output_hash_results)
    series_to_plot = []
    index_in_legend = @sorted_parameters_names.size;

    @series_names.each {|single_of_series_name|
      data_for_single = []
      @sorted_parameters_names.each{|sorted_parameter_name|
        data_for_single.push(output_hash_results[sorted_parameter_name][single_of_series_name].to_f)
      }
      series_to_plot.push({ name: single_of_series_name, data: data_for_single, legendIndex: index_in_legend})
      index_in_legend -= 1
    }

    @series_to_plot = series_to_plot
  end

  def extract_categories_xAxis(output_hash_output_results)
    @parameters_names = output_hash_output_results.keys
  end

  def extract_categories_series(output_hash_results)
    @series_names = output_hash_results[output_hash_results.keys[0]].keys
  end

end
