require 'rinruby'
require 'csv'
class Dendrogram
  attr_accessor :experiment
  attr_accessor :parameters
  include Scalarm::ServiceCore::ParameterValidation

  ##
  # create data for chart and <script> which is rendered in ChartInstancesController
  def handler
    if parameters["id"] && parameters["array"]
      object = {}
      data = get_data_for_dendrogram
      if parameters["type"] == 'data'

        object = content[JSON.stringify(data)]
      elsif parameters["chart_id"]
        object = prepare_dendrogram_chart_content(data)
      else
        raise MissingParametersError.new(['chart_id']);

      end
      object
    end

  end

  ##
  # create <script> which is load on page
  def prepare_dendrogram_chart_content(data)
    output = "<script>(function() { \nvar i=" + parameters["chart_id"] + ";"
    output += "\nvar data = " + data.to_json + ";" if data != nil
    output += "\nvar prefix = \"" + @prefix.to_s + "\";"
    output += "\nvar experiment_id = \"" + experiment.id.to_s + "\";"
    output += "\ndendrogram_main(i, \"" + Array(parameters["array"]).to_sentence + "\", data, experiment_id, prefix);"
    output += "\n})();</script>"
    output
  end

  ##
  # prepare data for draw function
  def get_data_for_dendrogram
    if experiment.simulation_runs.to_a.length == 0
      raise SecurityError.new('No simulation runs done')
    end

    #getting data
    result_file = Tempfile.new('dendrogram')
    result_csv = create_result_csv

    IO.write(result_file.path, result_csv)
    #evaluate R commands
    R.eval <<EOF
    hdata <- hclust(dist(read.csv('#{result_file.path}')), 'complete')
    merge <- hdata$merge

EOF

    merge = R.pull "merge"

    #parsing matrix into hash: value -> left child, right child
    hash = {}
    for counter in 1..merge.row_size()
      hash[counter.to_s] = [merge[(counter-1), 0].to_i, merge[(counter-1), 1].to_i]
    end
    creating_dendrogram_structure(hash)
  end

  ##
  # search for -and pair and creating json with hierarchical structure to draw dendrogram
  def creating_dendrogram_structure(data)
    root = data.keys.last
    hash = create_hash(data, root, 0)
    create_json_max_depth(data, root, 0, get_the_best_depth(data, root, hash))
  end

  ##
  # get depth of dendrogram with max count of leafs equal 250
  def get_the_best_depth(data, root, hash)
    max_depth = get_max_depth(data, root, 0)
    (0..max_depth).each do |i|
      if count_of_leafs(hash, i, 0).to_i > 250
        return i-1
      end
    end
    return max_depth
  end

  ##
  # create hash with structure of dendrogram with depth, data = {'1'=>[-2,3],'3'=>[-4,-5]}, root = 1. depth = 0
  # return {"id"=>1, "depth"=>0, "children"=>[{"id"=>3, "depth"=>1, "children"=>[{"id"=>4}, {"id"=>5}]}, {"id"=>2}]}
  def create_hash(data, root, depth)
    d = data[root.to_s]
    if d[0] < 0 && d[1] < 0
      {"id" => root, "depth" => depth, "children" => [{"id" => -d[0]}, {"id" => -d[1]}]}
    elsif d[0] < 0 && d[1] > 0
      {"id" => root, "depth" => depth, "children" => [create_hash(data, d[1], depth+1), {"id" => -d[0]}]}
    elsif d[0] > 0 && d[1] < 0
      {"id" => root, "depth" => depth, "children" => [create_hash(data, d[0], depth+1), {"id" => -d[1]}]}
    elsif d[0] > 0 && d[1] > 0
      {"id" => root, "depth" => depth, "children" => [create_hash(data, d[0], depth+1), create_hash(data, d[1], depth+1)]}
    end if d!=nil
  end

  ##
  # get depth of dendrogram with max count of leafs equal 250, data = {'1'=>[-2,3],'3'=>[-4,-5]}
  # hash = {"id"=>1, "depth"=>0, "children"=>[{"id"=>3, "depth"=>1, "children"=>[{"id"=>4}, {"id"=>5}]}, {"id"=>2}]}
  # return integer
  def get_the_best_depth(data, root, hash)
    max_depth = get_max_depth(data, root, 0)
    (0..max_depth).each do |depth|
      if count_of_leafs(hash, depth, 0).to_i > 250
        return depth-1
      end
    end
    return max_depth
  end

  ##
  # return maximum depth of dendrogram, data = {'1'=>[-2,3],'3'=>[-4,-5]}
  def get_max_depth(data, root, depth)
    d = data[root.to_s]
    if d[0] < 0 && d[1] < 0
      depth+1
    elsif d[0] < 0 && d[1] > 0
      [get_max_depth(data, d[1], depth+1), depth].max
    elsif d[0] > 0 && d[1] < 0
      [get_max_depth(data, d[0], depth+1), depth]
    elsif d[0] > 0 && d[1] > 0
      [get_max_depth(data, d[0], depth+1), get_max_depth(data, d[1], depth+1)].max
    end if d!=nil
  end

  ##
  # get count of leafs (clusters and simulations) if depth of dendrogram = depth, hash = {'id'=>1, 'depth'=>0, 'children'=>[{'id'=>2}, {'id'=>3}]}
  def count_of_leafs(hash, depth, count)
    if hash['depth'] != nil and hash['depth'] < depth and hash['children'].kind_of?(Array)
      count = count + count_of_leafs(hash['children'][0], depth, count) + count_of_leafs(hash['children'][1], depth, count)
    else
      count = count + 1
      count
    end
  end

  ##
  # create json with dendrogram structure with all nodes, return {id: 1, children:[{id, children:[]}]}
  def create_json(data, root)
    d = data[root.to_s]
    if d[0] < 0 && d[1] < 0
      "{\"id\":\"#{root}\",\"children\":[{\"id\":\"#{-d[0]}\"},{\"id\":\"#{-d[1]}\"}]}"
    elsif d[0] < 0 && d[1] > 0
      "{\"id\":\"#{root}\",\"children\":[#{create_json(data, d[1])},{\"id\":\"#{-d[0]}\"}]}"
    elsif d[0] > 0 && d[1] < 0
      "{\"id\":\"#{root}\",\"children\":[#{create_json(data, d[0])},{\"id\":\"#{-d[1]}\"}]}"
    elsif d[0] > 0 && d[1] > 0
      "{\"id\":\"#{root}\",\"children\":[#{create_json(data, d[0])},#{create_json(data, d[1])}]}"
    end if d!=nil
  end

  ##
  # create json with dendrogram structure where max depth of dendrogram = max_depth
  # input data: {'1'=>[-2,3],'3'=>[-4,-5]}, root = 1, depth = 0, max_depth = 2
  # return {"id"=>1, "children"=>[{"id"=>3, "children"=>[{"id"=>4}, {"id"=>5}]}, {"id"=>2}]}
  def create_json_max_depth(data, root, depth, max_depth)
    d = data[root.to_s]
    if d[0] < 0 && d[1] < 0
      "{\"id\":\"#{root}\",\"children\":[{\"id\":\"#{-d[0]}\"},{\"id\":\"#{-d[1]}\"}]}"
    elsif d[0] < 0 && d[1] > 0
      if depth < max_depth-1
        "{\"id\":\"#{root}\",\"children\":[#{create_json_max_depth(data, d[1], depth+1, max_depth)},{\"id\":\"#{-d[0]}\"}]}"
      else
        "{\"id\":\"#{root}\",\"children\":[{\"id\":\"cl #{d[1]}\",\"simulations\":\"#{get_simulations_by_cluster(data, d[1])}\"},{\"id\":\"#{-d[0]}\"}]}"
      end
    elsif d[0] > 0 && d[1] < 0
      if depth < max_depth-1
        "{\"id\":\"#{root}\",\"children\":[#{create_json_max_depth(data, d[0], depth+1, max_depth)},{\"id\":\"#{-d[1]}\"}]}"
      else
        "{\"id\":\"#{root}\",\"children\":[{\"id\":\"cl #{d[0]}\",\"simulations\":\"#{get_simulations_by_cluster(data, d[0])}\"},{\"id\":\"#{-d[1]}\"}]}"
      end
    elsif d[0] > 0 && d[1] > 0
      if depth < max_depth-1
        "{\"id\":\"#{root}\",\"children\":[#{create_json_max_depth(data, d[0], depth+1, max_depth)},#{create_json_max_depth(data, d[1], depth+1, max_depth)}]}"
      else
        "{\"id\":\"#{root}\",\"children\":[{\"id\":\"cl #{d[0]}\",\"simulations\":\"#{get_simulations_by_cluster(data, d[0])}\"},{\"id\":\"cl #{d[1]}\",\"simulations\":\"#{get_simulations_by_cluster(data, d[1])}\"}]}"
      end
    end if d!=nil
  end

  ##
  # return simulations which are in subtree when cluster with id = cluster_id is the root
  def get_simulations_by_cluster(hash, cluster_id)
    d = hash[cluster_id.to_s]
    if d[0] < 0 && d[1] < 0
      [-d[0], -d[1]].join(', ')
    elsif d[0] < 0 && d[1] > 0
      [-d[0], get_simulations_by_cluster(hash, d[1])].join(', ')
    elsif d[0] > 0 && d[1] < 0
      [get_simulations_by_cluster(hash, d[0]), -d[1]].join(', ')
    elsif d[0] > 0 && d[1] > 0
      [get_simulations_by_cluster(hash, d[0]), get_simulations_by_cluster(hash, d[1])].join(', ')
    end if d!=nil
  end

  ##
  # create data for done simulation in csv format, header: simulation_index,parameter1,parameter2,moe
  def create_result_csv(with_index=true, with_params=true, with_moes=true)
    moes = Array(parameters["array"])
    if with_params
      all_parameters = experiment.get_parameter_ids.uniq.flatten
    end
    CSV.generate do |csv|
      header = []
      header += ['simulation_index'] if with_index
      header += all_parameters if with_params
      header += moes if with_moes
      csv << header

      query_fields = {_id: 0}
      query_fields[:index] = 1 if with_index
      if with_params
        query_fields[:input_parameters] = 1
        query_fields[:values] = 1
      end
      query_fields[:result] = 1 if with_moes

      experiment.simulation_runs.where(
          {is_done: true, is_error: {'$exists' => false}},
          {fields: query_fields}
      ).each do |simulation_run|
        csv << create_line_csv(simulation_run, moes)
      end
    end
  end

  ##
  # create data for simulation run in csv format, columns: simulation_index,parameter1,parameter2,moe
  def create_line_csv(simulation_run, moes)
    line = []
    line += [simulation_run.index]
    line += simulation_run.values.split(',')
    # getting values of results in a specific order
    line += moes.map { |moe_name| simulation_run.result[moe_name] || '' }
    line
  end
end