class C50
  attr_accessor :experiment
  attr_accessor :parameters

  attr_reader :types_of_parameters_for_input
  attr_reader :types_of_parameters_for_output


  require "json"
  require "rinruby"
  require 'csv'

  def prepare_c50_chart_content(data)
    output = "<script>(function() { \nvar i=" + parameters["chart_id"] + ";"
    output += "\nvar data = " + data.to_json + ";" #if data != nil
    output += "\nc50_main(i, data);"
    output += "\n})();</script>"
    output
  end

  def handler()
    if parameters["id"] && parameters["chart_id"] && parameters["output"]
      object = {}
      data = {} #future data for c50
      File.open("yourfile2.txt", 'w') { |file| file.write(experiment.simulation_runs.first.arguments.split(',')) }
      #types_of_all_parameters()
      data = get_data_for_c50() #will be used for above variable
      object = prepare_c50_chart_content(data)
      return object
    else
      raise("Request parameters missing")
    end

  end

  def get_data_for_c50()
    # simulation_runs = experiment.simulation_runs.to_a
    rinruby = Rails.configuration.r_interpreter

    File.open("yourfile.txt", 'w') { |file| file.write("R.treeStruct") }
    #evaluate R commands
    result_file = Tempfile.new('dendrogram')
    result_csv = create_result_csv

    IO.write(result_file.path, result_csv)

    R.eval <<EOF
      library("rjson")
      library("C50")
      #dataFrame <- data.frame(replicate(2,sample(0:100,200,rep=TRUE)))
      #dataFrame$X1 <- factor(dataFrame$X1)
      #dataFrame$X2 <- factor(dataFrame$X2)
      #write.csv(colnames(dataFrame), file = "MyData.csv")
      #write.csv(dataFrame, file = "MyData1.csv")
      #data <- read.csv('#{result_file.path}', head=TRUE, sep=",")
      #dataFrame$simulation_index <- NULL

      dataFrame <- data.frame(read.csv('#{result_file.path}'))
      indexOfParameter <- grep("#{parameters["output"]}", colnames(dataFrame))
      write.csv(indexOfParameter, file = "MyData.csv")
      dataFrame$#{parameters["output"]} <- factor(dataFrame$#{parameters["output"]})
      treeStruct <- C5.0(dataFrame[, -indexOfParameter], dataFrame$#{parameters["output"]})
	    rulesStruct <- C5.0(dataFrame[, -indexOfParameter], dataFrame$#{parameters["output"]}, rules = TRUE )
      lst <- list(levels = treeStruct$levels,
			  predictors = treeStruct$predictors,
				tree = treeStruct$tree,
        rules = rulesStruct$rules,
        decision = treeStruct$output
            )
      values <- as.character(toJSON(lst))
EOF

    data = JSON.parse R.values
    File.open("yourfile.txt", 'w') { |file| file.write(R.values) }
    return data
  end

  def moe_names(with_strings_parameter=false)
    moe_name_set = []
    limit = @experiment.size > 1000 ? @experiment.size / 2 : @experiment.size
    @experiment.simulation_runs.where({ is_done: true }, { fields: %w(result), limit: limit }).each do |simulation_run|
      simulation_run.result.keys.to_a.each do |moe|
        #if (@types_of_parameters_for_output[moe] != 'string')
          moe_name_set += simulation_run.result.keys.to_a
        #end
      end
    end

    moe_name_set.uniq
  end

  def parameters_names(with_strings_parameter=false)
    parameters_names = []

    @experiment.experiment_input.each do |entity_group|
      entity_group['entities'].each do |entity|
        entity['parameters'].each do |parameter|
          parameters_names << @experiment.get_parameter_ids unless parameter.include?('in_doe') and parameter['in_doe'] == true
        end
      end
    end

    parameters_names
  end

  def create_result_csv(with_index=false, with_params=true, with_moes=true)
    moes = moe_names
    if with_params
      all_parameters = parameters_names.uniq.flatten
    end
    CSV.generate do |csv|
      header = []
      header += ['simulation_index'] if with_index
      header += all_parameters if with_params
      header += moes if with_moes
      csv << header

      query_fields = {_id: 0}
      query_fields[:index] = 1 if with_index
      query_fields[:values] = 1 if with_params
      query_fields[:result] = 1 if with_moes

      @experiment.simulation_runs.where(
          {is_done: true, is_error: {'$exists' => false}},
          {fields: query_fields}
      ).each do |simulation_run|
        line = []
        line += [simulation_run.index] if with_index
        line += simulation_run.values.split(',') if with_params
        # getting values of results in a specific order
        line += moes.map { |moe_name| simulation_run.result[moe_name] || '' } if with_moes

        csv << line
      end
    end
  end

  def types_of_all_parameters
    simulation_runs = experiment.simulation_runs.to_a.first.values.split(',')
    argument_ids= experiment.simulation_runs.first.arguments.split(',')

    argument_ids.each_with_index do |data, index|
      item = simulation_runs[index]
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

  end


end