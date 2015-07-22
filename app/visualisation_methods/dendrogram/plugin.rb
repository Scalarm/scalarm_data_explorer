require 'rinruby'
require 'csv'
class Dendrogram
  attr_accessor :experiment
  attr_accessor :parameters


  def handler
    if parameters["id"] && parameters["array"]
      object = {}
      data = get_data_for_dendrogram(experiment, parameters["id"], parameters["array"].first)
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

  def prepare_dendrogram_chart_content(data)
    output = "<script>(function() { \nvar i=" + parameters["chart_id"] + ";"
    output += "\nvar data = " + data.to_json + ";" if data != nil
    output += "\nvar prefix = \"" + @prefix.to_s + "\";"
    output += "\nvar experiment_id = \"" + @experiment.id.to_s + "\";"
    output += "\ndendrogram_main(i, \"" + parameters["array"].first + "\", data, experiment_id, prefix);"
    output += "\n})();</script>"
    output
  end


  # TODO: documentation - what this method does? change name
  def get_data_for_dendrogram(experiment, id, param_x)

    # simulation_runs = experiment.simulation_runs.to_a
    rinruby = Rails.configuration.r_interpreter

    #getting data
    result_file = Tempfile.new('dendrogram')
    result_csv = create_result_csv

    IO.write(result_file.path, result_csv)

    #evaluate R commands
    R.eval <<EOF
    hdata <- hclust(dist(read.csv('#{result_file.path}')), 'complete')
    merge <- hdata$merge

EOF

    #parameters - lst  NOTE!!!! THIS STRUCTURE IS VERY BIG

    #structure of the tree (matrix)
    merge = R.pull "merge"

    #parsing matrix into hash: value -> left child, right child
    hash = {}
    for counter in 1..merge.row_size()
      hash[counter.to_s] = [merge[(counter-1),0].to_i, merge[(counter-1),1].to_i]
    end
    creating_dendrogram_structure(hash)
  end


  def creating_dendrogram_structure(data)
# search for - and - pairs and creating dict output value -> this pair
    root = data.keys.last
    create_json(data, root)
  end


  def create_json(hash, node)
    d = hash[node.to_s]
    if d[0] < 0 && d[1] < 0
      "{\"id\":\"#{node}\",\"children\":[{\"id\":\"#{-d[0]}\"},{\"id\":\"#{-d[1]}\"}]}"
    elsif d[0] < 0 && d[1] > 0
      "{\"id\":\"#{node}\",\"children\":[#{create_json(hash, d[1])},{\"id\":\"#{-d[0]}\"}]}"
    elsif d[0] > 0 && d[1] < 0
      "{\"id\":\"#{node}\",\"children\":[#{create_json(hash, d[0])},{\"id\":\"#{-d[1]}\"}]}"
    elsif d[0] > 0 && d[1] > 0
      "{\"id\":\"#{node}\",\"children\":[#{create_json(hash, d[0])},#{create_json(hash, d[1])}]}"
    end if d!=nil

  end


  def moe_names
    moe_name_set = []
    limit = @experiment.size > 1000 ? @experiment.size / 2 : @experiment.size
    @experiment.simulation_runs.where({ is_done: true }, { fields: %w(result), limit: limit }).each do |simulation_run|
      moe_name_set += simulation_run.result.keys.to_a
    end
    Rails.logger.debug(moe_name_set.uniq)
    Rails.logger.debug("!!!!!!!!!!!!!!!!!!!!!!!!!!!")
    moe_name_set.uniq

  end

  def parameters_names
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

  def create_result_csv(with_index=true, with_params=true, with_moes=true)
    moes = parameters["array"]
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
end