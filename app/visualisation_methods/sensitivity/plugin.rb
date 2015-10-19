require 'json'

class Sensitivity
  attr_accessor :experiment
  attr_accessor :parameters

  attr_reader :series_to_plot
  attr_reader :parameters_names
  attr_reader :sorted_parameters_names
  attr_reader :name_of_output
  attr_reader :series_names
  attr_reader :list_of_methods
  attr_reader :method_name

  def prepare_sensitivity_chart_content
    output = "<script>(function() { \nvar i=" + parameters["chart_id"] + ";"
    output += "\nvar sorted_parameters_names = " + @sorted_parameters_names.to_json + ";"
    output += "\nvar series_to_plot = " +  @series_to_plot.to_json + ";"
    output += "\nvar method_name = " +  @method_name.to_json + ";"
    output += "\nsensitivity_main(i, series_to_plot, sorted_parameters_names, method_name);"
    output += "\n})();</script>"
    output
  end

  ##
  # We assume that the result json have specific format:
  #   morris method:
  #   {
  #     "sensitivity_analysis_method":"morris",
  #     "moes":{
  #       "moe1":{
  #         "parameter1":{
  #           "mean":3,
  #           "st.deviation ":2
  #         },
  #         "parameter2":{
  #           "mean":-1,
  #           "st.deviation ":4
  #         }
  #       },
  #       "moe2":{
  #         "parameter1":{
  #           "mean":5,
  #           "st.deviation ":1
  #          },
  #          "parameter2":{
  #           "mean":0,
  #           "st.deviation ":2
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

  def handler()
    if parameters["id"] && parameters["chart_id"] && parameters["output"]
      @name_of_output = parameters["output"]
      @list_of_methods = ["morris", "fast"]
      output_hash = @experiment.results

      if !@list_of_methods.include? output_hash["sensitivity_analysis_method"]
        raise("No visualization for #{output_hash["sensitivity_analysis_method"]} method")
      end

      if @experiment.error_reason != nil
        raise ("Error appeared - #{@experiment.error_reason}")
      end

      output_hash_results = output_hash['moes'][@name_of_output]

      if !output_hash_results
        raise("No #{@name_of_output} in moes results from supervised experiment")
      end

      extract_categories_x_axis(output_hash_results)
      extract_categories_series(output_hash_results)
      sort_parameters_names(output_hash_results)

      case output_hash["sensitivity_analysis_method"]
        when "morris"
         @method_name = "morris"
         extract_morris_series(output_hash_results)
         do_normalization
        when "fast"
         @method_name = "fast"
         extract_fast_series(output_hash_results)
        else
         raise("No visualization for #{output_hash["sensitivity_analysis_method"]} method")
        end

      object = prepare_sensitivity_chart_content
      object
    else
      raise("Request parameters missing")
    end

  end

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

    @series_to_plot = series_to_plot
  end

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

    @series_to_plot = series_to_plot
  end

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

    @series_to_plot = series_to_plot
  end

  def extract_categories_x_axis(output_hash_output_results)
    @parameters_names = output_hash_output_results.keys
  end

  def extract_categories_series(output_hash_results)
    @series_names = output_hash_results[output_hash_results.keys[0]].keys
  end

  def do_normalization
    series_to_plot = []
    @series_to_plot.each do |single_of_series_name|
      total_sum = single_of_series_name[:data].inject(0) {|sum, i|  sum + i.abs }
      proper_name = I18n.t ("sensitivity_analysis.morris." + single_of_series_name[:name])
      series_to_plot.push({name: proper_name, data: single_of_series_name[:data].map{|single_data_value| ((single_data_value / total_sum)).round(2) }, legendIndex: single_of_series_name[:legendIndex]})
    end

    @series_to_plot = series_to_plot
  end

end
