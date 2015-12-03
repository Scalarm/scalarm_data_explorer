require 'json'

class Sensitivity
  attr_accessor :experiment
  attr_accessor :parameters

  attr_reader :plot_series
  attr_reader :parameters_names
  attr_reader :sorted_parameters_names
  attr_reader :output_name
  attr_reader :series_names
  attr_reader :methods_list
  attr_reader :method_name

  def prepare_sensitivity_chart_content
    output = "<script>(function() { \nvar i=" + parameters["chart_id"] + ";"
    output += "\nvar sorted_parameters_names = " + @sorted_parameters_names.to_json + ";"
    output += "\nvar series_to_plot = " +  @plot_series.to_json + ";"
    output += "\nvar method_name = " +  @method_name.to_json + ";"
    output += "\nsensitivity_main(i, series_to_plot, sorted_parameters_names, method_name);"
    output += "\n})();</script>"
    output
  end

  #
  # We assume that the result json have specific format:
  #   morris method:
  #   {
  #     "sensitivity_analysis_method":"morris",
  #     "moes":{
  #       "moe1":{
  #         "parameter1":{
  #           "standard_deviation":3,
  #           "absolute_mean":2,
  #           "mean":1
  #         },
  #         "parameter2":{
  #           "standard_deviation":-1,
  #           "absolute_mean":4,
  #           "mean":1
  #         }
  #       },
  #       "moe2":{
  #         "parameter1":{
  #           "standard_deviation":5,
  #           "absolute_mean ":1,
  #           "mean":1
  #          },
  #          "parameter2":{
  #           "standard_deviation":0,
  #           "absolute_mean ":2,
  #           "mean":1
  #          }
  #       }
  #     }
  #    }
  #
  #   fast method:
  #   {
  #     "sensitivity_analysis_method":"fast",
  #     "moes":{
  #       "moe2":{
  #         "parameter1":{
  #           "first_order":0.21,
  #           "total_order":0.45
  #         },
  #         "parameter2":{
  #           "first_order":0.32,
  #           "total_order":0.23
  #         }
  #       },
  #       "moe1":{
  #         "parameter1":{
  #           "first_order":0.23,
  #           "total_order":0.34
  #         },
  #         "parameter2":{
  #           "first_order":0.31,
  #           "total_order":0.64
  #         }
  #       }
  #     }
  #   }
  #
  #   pcc method:
  #   {
  #     "sensitivity_analysis_method":"pcc",
  #     "moes":{
  #       "moe2":{
  #         "parameter1":{
  #           "original":0.21,
  #           "min_ci":0.15,
  #           "max_ci": 0.26
  #         },
  #         "parameter2":{
  #           "original":0.41,
  #           "min_ci":0.35,
  #           "max_ci": 0.56
  #         }
  #       },
  #       "moe1":{
  #         "parameter1":{
  #           "original":0.21,
  #           "min_ci":0.15,
  #           "max_ci": 0.26
  #         },
  #         "parameter2":{
  #           "original":0.41,
  #           "min_ci":0.35,
  #           "max_ci": 0.56
  #         }
  #       }
  #     }
  #   }

  def handler
    if parameters["id"] && parameters["chart_id"] && parameters["output"]
      @output_name = parameters["output"]
      @methods_list = ["morris", "fast", "pcc"]
      output_hash = @experiment.results

      if !@methods_list.include? output_hash["sensitivity_analysis_method"]
        raise("No visualization for #{output_hash["sensitivity_analysis_method"]} method")
      end

      if @experiment.error_reason != nil
        raise ("The experiment ended with error: - #{@experiment.error_reason}")
      end

      output_hash_results = output_hash['moes'][@output_name]

      if !output_hash_results
        raise("No #{@output_name} in moes results from supervised experiment")
      end

      extract_categories_x_axis(output_hash_results)
      sort_parameters_names(output_hash_results)

      case output_hash["sensitivity_analysis_method"]
        when "morris"
          extract_categories_series(output_hash_results)
          morris_visualization(output_hash_results)
        when "fast"
          extract_categories_series(output_hash_results)
          fast_visualization(output_hash_results)
        when "pcc"
          pcc_visualization(output_hash_results)
        else
          raise("No visualization for #{output_hash["sensitivity_analysis_method"]} method")
      end

      object = prepare_sensitivity_chart_content
      object
    else
      raise("Request parameters missing (required: id, chart_id i output)")
    end

  end


  # Call methods in order to prepare visualization of morris method
  #
  # * *Args*:
  #   - +output_hash_output_results+ -> json with with output for specific moe variable (specified from user in modal in selector)
  #
  def morris_visualization(output_hash_results)
    @method_name = "morris"
    extract_morris_series(output_hash_results)
    normalize
  end

  # Call methods in order to prepare visualization of fast method
  #
  # * *Args*:
  #   - +output_hash_output_results+ -> json with with output for specific moe variable (specified from user in modal in selector)
  #
  def fast_visualization(output_hash_results)
    @method_name = "fast"
    extract_fast_series(output_hash_results)
  end

  # Call methods in order to prepare visualization of pcc method
  #
  # * *Args*:
  #   - +output_hash_output_results+ -> json with with output for specific moe variable (specified from user in modal in selector)
  #
  def pcc_visualization(output_hash_results)
    @method_name = "pcc"
    extract_pcc_series(output_hash_results)
  end


  # Sort parameter names in instance variable @parameters_names in order to growing common value from their coefficients
  #
  # * *Args*:
  #   - +output_hash_output_results+ -> json with with output for specific moe variable (specified from user in modal in selector)
  #
  # * *Outputs*:
  #   {"parameter1":{ "standard_deviation":0.81,"absolute_mean":0.55,"mean": 0.56},
  #   "parameter2":{ "standard_deviation":0.41, "absolute_mean":0.15, "mean": 0.16} ->
  #   sorted_parameters_names = [parameter2, parameter1]
  #
  def sort_parameters_names(output_hash_results)
    sorted_parameters_names = {}

    @parameters_names.each do |name_of_parameter|
      parameter_total_sum = 0.0
      output_hash_results[name_of_parameter].each_key do |key|
        parameter_total_sum += output_hash_results[name_of_parameter][key]
      end
      sorted_parameters_names[name_of_parameter] = parameter_total_sum
    end

    @sorted_parameters_names = sorted_parameters_names.sort_by{ |k, v| v }.to_h.keys
  end


  # Extract data to plot to instance variable @plot_series for morris method
  #
  # * *Args*:
  #   - +output_hash_output_results+ -> json with with output for specific moe variable (specified from user in modal in selector)
  #
  # * *Outputs*:
  #   {"parameter1":{ "standard_deviation":0.21,"absolute_mean":0.15,"mean": 0.26},
  #   "parameter2":{ "standard_deviation":0.41, "absolute_mean":0.35, "mean": 0.56} ->
  #   -> plot_series =
  #   {name: "standard_deviation", data: [0.41, 0.21], legendIndex: 1},
  #   {name: "absolute_mean", data: [0.35, 0.15], legendIndex: 2}
  #   {name: "mean", data: [0.56, 0.26], legendIndex: 3}}
  #
  def extract_morris_series(output_hash_results)
    series_to_plot = []
    index_in_legend = @sorted_parameters_names.size;

    @series_names.each do |single_of_series_name|
      data_for_single = []
      @sorted_parameters_names.each do |sorted_parameter_name|
        data_for_single.push(output_hash_results[sorted_parameter_name][single_of_series_name].to_f)
      end
      series_to_plot.push({ name: single_of_series_name, data: data_for_single, legendIndex: index_in_legend})
      index_in_legend -= 1
    end

    @plot_series = series_to_plot
  end

  # Extract data to plot to instance variable @plot_series for fast method and add proper name for coefficients from en.yml
  #
  # * *Args*:
  #   - +output_hash_output_results+ -> json with with output for specific moe variable (specified from user in modal in selector)
  #
  # * *Outputs*:
  #   {"parameter1":{ "first_order":0.21,"total_order":0.25},
  #   "parameter2":{ "first_order":0.35, "total_order":0.41} ->
  #   -> plot_series =
  #   {name: "Main effect", data: [0.35, 0.21], legendIndex: 1}
  #   {name: "Interactions", data: [0.06, 0.04], legendIndex: 2}}
  def extract_fast_series(output_hash_results)
    @sorted_parameters_names = (@sorted_parameters_names).reverse
    series_to_plot = []
    index_in_legend = @sorted_parameters_names.size;

    @series_names.each do |single_of_series_name|
      data_for_single = []
      @sorted_parameters_names.each do |sorted_parameter_name|
        if single_of_series_name == "total_order"
          data_for_single.push((output_hash_results[sorted_parameter_name][single_of_series_name].to_f - output_hash_results[sorted_parameter_name]["first_order"].to_f).round(3))
        else
          data_for_single.push((output_hash_results[sorted_parameter_name][single_of_series_name].to_f).round(3))
        end
      end
      proper_name = I18n.t ("sensitivity_analysis.fast." + single_of_series_name)
      series_to_plot.push({ name: proper_name, data: data_for_single, legendIndex: index_in_legend})
      index_in_legend -= 1
    end

    @plot_series = series_to_plot
  end

  # Extract data to plot to instance variable @plot_series for PCC method
  #
  # * *Args*:
  #   - +output_hash_output_results+ -> json with with output for specific moe variable (specified from user in modal in selector)
  #
  # * *Outputs*:
  #   {"parameter1":{ "original":0.21,"min_ci":0.15,"max_ci": 0.26},
  #   "parameter2":{ "original":0.41, "min_ci":0.35, "max_ci": 0.56} ->
  #   -> @plot_series =
  #   plot_series["error_data"] = [[0.15, 0.26], [0.35, 0.56]]
  #   plot_series["scatter_data"] = [0.21, 0.41]
  #
  def extract_pcc_series(output_hash_results)
    scatter_data = []
    error_data = []

    @sorted_parameters_names = @sorted_parameters_names.reverse!
    @sorted_parameters_names.each do |sorted_parameter_name|
      scatter_data.push(output_hash_results[sorted_parameter_name]["original"].to_f)
      error_data.push([output_hash_results[sorted_parameter_name]["min_ci"].to_f,
                       output_hash_results[sorted_parameter_name]["max_ci"].to_f])
    end

    @plot_series = {}
    @plot_series["error_data"] = error_data
    @plot_series["scatter_data"] =  scatter_data
  end

  # Extract categories from json output to instance variable @parameters_names
  #
  # * *Args*:
  #   - +output_hash_output_results+ -> json with with output for specific moe variable (specified from user in modal in selector)
  #
  # * *Outputs*:
  #   {"parameter1":{ "original":0.21,"min_ci":0.15,"max_ci": 0.26},
  #   "parameter2":{ "original":0.41, "min_ci":0.35, "max_ci": 0.56} ->
  #   -> parameters_names = [parameter1, parameter2]
  #
  def extract_categories_x_axis(output_hash_output_results)
    @parameters_names = output_hash_output_results.keys
  end

  # Extract serier from json output to instance variable @series_names
  #
  # * *Args*:
  #   - +output_hash_output_results+ -> json with with output for specific moe variable (specified from user in modal in selector)
  #
  # * *Outputs*:
  #   {"parameter1":{ "original":0.21,"min_ci":0.15,"max_ci": 0.26},
  #   "parameter2":{ "original":0.41, "min_ci":0.35, "max_ci": 0.56} ->
  #   -> series_names = [original, min_ci, max_ci]
  #
  def extract_categories_series(output_hash_results)
    @series_names = output_hash_results[output_hash_results.keys[0]].keys
  end

  # Normalize output in instance variable @plot_series for morris method and take proper name from en.yml for coefficient
  #
  # * *Outputs*:
  #   {{name: "standard_deviation",  data:[1, 2, 7], legendIndex: 1},
  #   {name: "mean",  data:[1, 1, 1], legendIndex: 2},
  #   {name: "absolute_mean", data:[1, 2, 2], legendIndex: 3}} ->
  #   -> plot_series =
  #   {{name: "Standard deviation",  data:[0.1, 0.2, 0.7], legendIndex: 1},
  #   {name: "Mean",  data:[0.33, 0.33, 0.33], legendIndex: 2},
  #   {name: "Absolute mean", data:[0.2, 0.4, 0.4], legendIndex: 3}}
  #
  def normalize
    series_to_plot = []
    @plot_series.each do |single_of_series_name|
      total_sum = single_of_series_name[:data].inject(0) {|sum, i|  sum + i.abs }
      proper_name = I18n.t ("sensitivity_analysis.morris." + single_of_series_name[:name])
      series_to_plot.push({name: proper_name, data: single_of_series_name[:data].map{|single_data_value| ((single_data_value / total_sum)).round(2) }, legendIndex: single_of_series_name[:legendIndex]})
    end

    @plot_series = series_to_plot
  end

end
