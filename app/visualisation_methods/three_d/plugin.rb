class ThreeD

  attr_accessor :experiment
  attr_accessor :parameters

  attr_reader :types_of_parameters_for_all
  attr_reader :types_of_parameters_for_input
  attr_reader :types_of_parameters_for_output

  attr_reader :categories_for_x
  attr_reader :categories_for_y
  attr_reader :categories_for_z

  attr_reader :type_of_x
  attr_reader :type_of_y
  attr_reader :type_of_z

  def prepare_3d_chart_content(data)
    output = "<script>(function() { \nvar i=" + parameters["chart_id"] + ";"
    output += "\nvar categories_for_x = " + @categories_for_x.to_json + ";"
    output += "\nvar categories_for_y = " + @categories_for_y.to_json + ";"
    output += "\nvar categories_for_z = " + @categories_for_z.to_json + ";"
    output += "\nvar data = " + data.to_json + ";" if data != nil
    output += "\nthreeD_main(i, \"" + parameters["param_x_label"] + "\", \"" + parameters["param_y_label"] + "\", \"" + parameters["param_z_label"] + "\", data, \"" + @type_of_x + "\", \"" + @type_of_y + "\", \"" + @type_of_z + "\", categories_for_x, categories_for_y, categories_for_z);"
    output += "\n})();</script>"
    output

  end

  def handler
    if parameters["id"] && parameters["chart_id"] && parameters["param_x"] && parameters["param_y"] && parameters["param_z"]
      simulation_runs = experiment.simulation_runs.to_a

      if simulation_runs.length == 0
        raise("No such experiment or no runs done")
      end

      @types_of_parameters_for_all = {}
      @types_of_parameters_for_input = {}
      @types_of_parameters_for_output = {}

      @categories_for_x = []
      @categories_for_y = []
      @categories_for_z = []

      @type_of_x = ""
      @type_of_y = ""
      @type_of_z = ""

      argument_ids = simulation_runs.first.arguments.split(',')
      array_of_parameters_in_case = [parameters["param_x"],  parameters["param_y"], parameters["param_z"]]

      types_of_all_parameters(simulation_runs, argument_ids)
      types_of_xyz_parameters(array_of_parameters_in_case)
      generate_categories_for_string_parameters(simulation_runs, array_of_parameters_in_case)
      data = get3d(parameters["param_x"], parameters["param_y"], parameters["param_z"], simulation_runs, argument_ids)
      object = prepare_3d_chart_content(data)
      object
    else
      raise("Request parameters missing")
    end
  end

  def types_of_all_parameters(simulation_runs, argument_ids)
    arguments_values = simulation_runs.first.values.split(',')

    argument_ids.each_with_index do |data, index|
      item = arguments_values[index]
      a = item.to_i
      b = item.to_f

      if item.eql?a.to_s
        @types_of_parameters_for_input[data] = "integer"
      elsif item.eql?b.to_s
        @types_of_parameters_for_input[data] = "float"
      elsif item.is_a? String
        @types_of_parameters_for_input[data] = "string"
      else
        @types_of_parameters_for_input[data] = "undefined"
      end
    end

    simulation_runs.first.result.each do |key, value|
      item = value

      if item.is_a? Integer
        @types_of_parameters_for_output[key] = "integer"
      elsif item.is_a? Float
        @types_of_parameters_for_output[key] = "float"
      elsif item.is_a? String
        @types_of_parameters_for_output[key] = "string"
      else
        @types_of_parameters_for_output[key] = "undefined"
      end
    end

    @types_of_parameters_for_all = @types_of_parameters_for_output.merge(@types_of_parameters_for_input)
  end

  def types_of_xyz_parameters(array_of_parameters_in_case)
    array_of_parameters_in_case.each_with_index do |parameter, index|
      if index == 0
        @type_of_x = @types_of_parameters_for_all[parameter]
      elsif index == 1
        @type_of_y = @types_of_parameters_for_all[parameter]
      else
        @type_of_z = @types_of_parameters_for_all[parameter]
      end
    end
  end

  def generate_categories_for_string_parameters(simulation_runs, array_of_parameters_in_case)

    @types_of_parameters_for_input.each do |key, value|
      if value == "string" &&  array_of_parameters_in_case.include?(key)
        index_of_output_among_all_input = @types_of_parameters_for_input.keys.index(key)
        array_for_categories = []

        simulation_runs.map do |data|
          values = data.values.split(',')
          array_for_categories.push(values[index_of_output_among_all_input])
        end

        array_of_parameters_in_case.each_with_index do |arg_name, index|
          if arg_name == key
            if index == 0
              @categories_for_x = array_for_categories
            elsif index == 1
              @categories_for_y = array_for_categories
            else
              @categories_for_z = array_for_categories
            end
          end
        end
      end
    end

    @types_of_parameters_for_output.each do |key, value|
      if value == "string" &&  array_of_parameters_in_case.include?(key)
        #index_of_output_among_all_outputs = @types_of_parameters_for_output.keys.index(key)

        array_for_categories = []
        simulation_runs.map do |data|
          single_string = data.result[key]
          array_for_categories.push(single_string)
        end
        array_for_categories = array_for_categories.sort
        array_for_categories = array_for_categories.uniq

        array_of_parameters_in_case.each_with_index do |arg_name, index|
          if arg_name == key
            if index == 0
              @categories_for_x = array_for_categories
            elsif index == 1
              @categories_for_y = array_for_categories
            else
              @categories_for_z = array_for_categories
            end
          end
        end
      end
    end

  end

  def get3d(param_x, param_y, param_z, simulation_runs, argument_ids)
    simulation_runs = simulation_runs.map do |data|
      obj ={}
      values = data.values.split(',')
      new_args = {}

      argument_ids.each_with_index do |arg_name, index|
        if @types_of_parameters_for_input[arg_name] == 'string'
          if param_x == arg_name
            new_args[arg_name] = @categories_for_x.index(values[index])
          end
          if param_y == arg_name
            new_args[arg_name] = @categories_for_y.index(values[index])
          end
          if param_z == arg_name
            new_args[arg_name] = @categories_for_z.index(values[index])
          end
        else
          new_args[arg_name] = values[index].to_f
        end
      end

      obj[:arguments] = new_args
      obj[:result] = {}
      unless data.result.nil?
        data.result.each do |key, value|
          if @types_of_parameters_for_output[key] == 'string'
            if param_x == key
              obj[:result][key] = @categories_for_x.index(value)
            end
            if param_y == key
              obj[:result][key] = @categories_for_y.index(value)
            end
            if param_z == key
              obj[:result][key] = @categories_for_z.index(value)
            end
          else
            obj[:result][key] = value.to_f rescue 0.0
          end
        end
      end

      obj
    end

    data = []

    #counter = Array.new(simulation_runs.size, &:next)
    #simulation_runs.size
    counter  = 0
    if argument_ids.index(param_x)
      simulation_runs.map do |data_sim|

        data[counter] = [data_sim[:arguments][param_x]]
        counter+=1
      end
    else
      simulation_runs.map do |data_sim|

        data[counter] = [data_sim[:result][param_x]]
        counter+=1

      end
    end

    counter  = 0
    if argument_ids.index(param_y)
      simulation_runs.map do |data_sim|

        data[counter].push(data_sim[:arguments][param_y])
        counter+=1
      end
    else
      simulation_runs.map do |data_sim|

        data[counter].push(data_sim[:result][param_y])
        counter+=1

      end
    end

    counter  = 0
    if argument_ids.index(param_z)
      simulation_runs.map do |data_sim|

        data[counter].push(data_sim[:arguments][param_z])
        counter+=1
      end
    else
      simulation_runs.map do |data_sim|

        data[counter].push(data_sim[:result][param_z])
        counter+=1

      end
    end

    data
  end


end