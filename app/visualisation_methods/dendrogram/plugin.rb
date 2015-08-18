require 'rinruby'
require 'csv'
class Dendrogram
  attr_accessor :experiment
  attr_accessor :parameters






  def handler
    if parameters["id"] && parameters["array"]
      object = {}
      data = get_data_for_dendrogram
      if parameters["type"] == 'data'

        object = content[JSON.stringify(data)]
      elsif parameters["chart_id"]
        object = prepare_dendrogram_chart_content(data)
      else
        raise("Request parameters missing: 'chart_id'");

      end
      object
    end

  end

  def prepare_dendrogram_chart_content(data)
    output = "<script>(function() { \nvar i=" + parameters["chart_id"] + ";"
    output += "\nvar data = " + data.to_json + ";" if data != nil
    output += "\nvar prefix = \"" + @prefix.to_s + "\";"
    output += "\nvar experiment_id = \"" + @experiment.id.to_s + "\";"
    output += "\ndendrogram_main(i, \"" + Array(parameters["array"]).to_sentence + "\", data, experiment_id, prefix);"
    output += "\n})();</script>"
    output
  end


  # TODO: documentation - what this method does? change name
  def get_data_for_dendrogram

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
    hash = create_hash(data, root, 0)


    create_json_max_depth(data, root, 0, get_the_best_depth(data, root, hash))
    #create_json(data, root)
  end

  def get_the_best_depth(data, root, hash)
    max_depth = get_max_depth(data, root, 0)
    (0..max_depth).each do |i|
      if count_of_leafs(hash, i, 0).to_i > 300
        return i-1
      end
    end
    return max_depth
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

  def create_hash(hash, node, depth)
    d = hash[node.to_s]
    if d[0] < 0 && d[1] < 0
      {"id" => node, "depth" => depth, "children" => [{"id" => -d[0]}, {"id" => -d[1]}]}
    elsif d[0] < 0 && d[1] > 0
      {"id" => node, "depth" => depth, "children" => [create_hash(hash, d[1], depth+1), {"id" => -d[0]}]}
    elsif d[0] > 0 && d[1] < 0
      {"id" => node, "depth" => depth, "children" => [create_hash(hash, d[0], depth+1), {"id" => -d[1]}]}
    elsif d[0] > 0 && d[1] > 0
      {"id" => node, "depth" => depth, "children" => [create_hash(hash, d[0], depth+1), create_hash(hash, d[1], depth+1)]}
    end if d!=nil
  end

  def count_of_leafs(tree, depth, count)
    if tree['depth'] != nil
      if tree['depth'] <= depth
        if tree['children'].kind_of?(Array)
          count = count + count_of_leafs(tree['children'][0], depth, count) + count_of_leafs(tree['children'][1], depth, count)
        else
          count = count + 1
          count
        end
      else
        count = count + 1
        count
      end
    else
      count = count + 1
      count
    end
  end


  def count_of_leafs_for_depth(hash, node, depth, leafs)
    d = hash[node.to_s]
    if leafs[depth.to_s] == nil
      leafs[depth.to_s] = d
    else
      leafs[depth.to_s] = leafs[depth.to_s] + d
    end
    if d[0] < 0 && d[1] < 0
      leafs
    elsif d[0] < 0 && d[1] > 0
      count_of_leafs_for_depth(hash, d[1], depth+1, leafs)
      leafs
    elsif d[0] > 0 && d[1] < 0
      count_of_leafs_for_depth(hash, d[0], depth+1, leafs)
      leafs
    elsif d[0] > 0 && d[1] > 0
      count_of_leafs_for_depth(hash, d[0], depth+1, leafs)
      count_of_leafs_for_depth(hash, d[1], depth+1, leafs)
      leafs
    end if d!=nil
  end

  def create_json_max_depth(hash, node, depth, max_depth)
    d = hash[node.to_s]
    if d[0] < 0 && d[1] < 0
      "{\"id\":\"#{node}\",\"children\":[{\"id\":\"#{-d[0]}\"},{\"id\":\"#{-d[1]}\"}]}"
    elsif d[0] < 0 && d[1] > 0
      if depth < max_depth
        "{\"id\":\"#{node}\",\"children\":[#{create_json_max_depth(hash, d[1], depth+1, max_depth)},{\"id\":\"#{-d[0]}\"}]}"
      else
        "{\"id\":\"#{node}\",\"children\":[{\"id\":\"cl #{d[1]}\",\"simulations\":\"#{get_simulations_by_cluster(hash, d[1])}\"},{\"id\":\"#{-d[0]}\"}]}"
      end
    elsif d[0] > 0 && d[1] < 0
      if depth < max_depth
        "{\"id\":\"#{node}\",\"children\":[#{create_json_max_depth(hash, d[0], depth+1, max_depth)},{\"id\":\"#{-d[1]}\"}]}"
      else
        "{\"id\":\"#{node}\",\"children\":[{\"id\":\"cl #{d[0]}\",\"simulations\":\"#{get_simulations_by_cluster(hash, d[0])}\"},{\"id\":\"#{-d[1]}\"}]}"
      end
    elsif d[0] > 0 && d[1] > 0
      if depth < max_depth
        "{\"id\":\"#{node}\",\"children\":[#{create_json_max_depth(hash, d[0], depth+1, max_depth)},#{create_json_max_depth(hash, d[1], depth+1, max_depth)}]}"
      else
        "{\"id\":\"#{node}\",\"children\":[{\"id\":\"cl #{d[0]}\",\"simulations\":\"#{get_simulations_by_cluster(hash, d[0])}\"},{\"id\":\"cl #{d[1]}\",\"simulations\":\"#{get_simulations_by_cluster(hash, d[1])}\"}]}"
      end
    end if d!=nil
  end

  def get_simulations_by_cluster(hash, node)
    d = hash[node.to_s]
    if d[0] < 0 && d[1] < 0
      [-d[0], -d[1]].join(', ')
    elsif d[0] < 0 && d[1] > 0
      [-d[0], get_simulations_by_cluster(hash, d[1])].join(', ')
    elsif d[0] > 0 && d[1] < 0
      [get_simulations_by_cluster(hash, d[0]), -d[1]].join(', ')
    elsif d[0] > 0 && d[1] > 0
      [get_simulations_by_cluster(hash, d[0]), get_simulations_by_cluster(hash,d[1])].join(', ')
    end if d!=nil
  end

  def get_max_depth(hash, node, depth)
    d = hash[node.to_s]
    if d[0] < 0 && d[1] < 0
      depth
    elsif d[0] < 0 && d[1] > 0
      [get_max_depth(hash, d[1], depth+1), depth].max
    elsif d[0] > 0 && d[1] < 0
      [get_max_depth(hash, d[0], depth+1), depth]
    elsif d[0] > 0 && d[1] > 0
      [get_max_depth(hash, d[0], depth+1), get_max_depth(hash, d[1], depth+1)].max
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
   # moes = parameters["array"]
    moes = Array(parameters["array"])
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