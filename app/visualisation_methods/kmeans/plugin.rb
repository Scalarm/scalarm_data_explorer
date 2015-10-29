require 'rinruby'
class Kmeans
  attr_accessor :experiment
  attr_accessor :parameters
  include Scalarm::ServiceCore::ParameterValidation

  def handler

    if parameters["id"] && parameters["array"]
      object = {}
      data, subclusters = get_data_for_kmeans
      if parameters["type"] == 'data'
        object = content[JSON.stringify(data)]
      elsif parameters["chart_id"]
        object = prepare_kmeans_chart_content(data, subclusters)
      else
        raise MissingParametersError.new(["chart_id"]);

      end
      object
    end
  end

  def prepare_kmeans_chart_content(data, subclusters)
    output = "<script>(function() { \nvar i=" + parameters["chart_id"] + ";"
    output += "\nvar data = " + data.to_json + ";" if data != nil
    output += "\nvar subclusters = " + subclusters.to_json + ";" if subclusters != nil
    output += "\nvar prefix = \"" + @prefix.to_s + "\";"
    output += "\nvar experiment_id = \"" + @experiment.id.to_s + "\";"
    output += "\nkmeans_main(i, \"" + Array(parameters[:array]).to_sentence + "\", data, subclusters, "+ parameters[:clusters].to_s + ", " + parameters[:subclusters].to_s + ", experiment_id, prefix);"
    output += "\n})();</script>"
    output
  end


  ##
  # prepare data for draw function
  #
  # Details:
  # At the start is created data set with simulations output values (moes) and array with all simulation indexes
  # Next data is groped into hash {moe_name => [moe values] } and assigned in R as vector
  # To k-means algorithm is passed a data.frame with all of moe vectors
  # Results from k-means algorithm are parsed into form {cluster_id => [simulation ids] }
  # Similarly it works for subclusters
  def get_data_for_kmeans

    if @experiment.simulation_runs.to_a.length ==0
      raise SecurityError.new("No simulation runs done")
    end

      #getting data
    moes = Array(parameters["array"])
    simulation_ind, result_data = create_data_result

    result_data = result_data.sort_by{|x,y|x}

    result_hash = {}
    result_data.map{|row| result_hash[row[0]]=row[1]}
    groped_by_moes = {}
    result_data.map do |row|
      row[1].each_with_index do |moe,ind|
        groped_by_moes[moes[ind]].kind_of?(Array)? groped_by_moes[moes[ind]].push(moe) :  groped_by_moes[moes[ind]] = [moe]
      end
    end

    # for 2 and more moes join arrays of result into one and pass as data.frame
    groped_by_moes.each do |k,v|
      R.assign(k , v)
    end

    R.eval <<EOF
    hdata <- kmeans(data.frame(#{moes.join(",")}),#{parameters[:clusters]})
    clusters <- hdata$cluster

EOF
    merge = R.pull "clusters"
    hash = {}

    # adding simulation index to result_data
    # hash structure: simulation_id => cluster_id
    for counter in 0..(merge.count()-1)
      hash[simulation_ind[counter]] = merge[counter]
    end
    # hash
    clusters = grouping_hash(hash, parameters[:clusters])

    # creating sublcusters hash
    subclusters = {}
    for counter in 1..(parameters[:clusters].to_i)
      subcluster_moes = result_hash.select{|k,v| clusters[counter].include?(k)}.values
      subclusters[counter] = subcluster_moes
    end

    result_subcluster =create_subclusters(simulation_ind, subclusters, clusters)

    # parsing subcluster data into {cluster_id => { subcluster_id => simulation_ids}} form
    subclusters_data = {}
    result_subcluster.each do |k,v|
      subclusters_data[k] = grouping_hash(v, parameters[:subclusters])
    end
    return clusters, subclusters_data

  end

  ##
  # for now is only table with moes names
  def create_header
    header = []
   # moes= moe_names#[parameters["array"]]
    moes = Array(parameters["array"])
  #  header+=['simulation_index']
    header += moes
    header

  end

  ##
  # input hash: simulation_indx => cluster_id
  # creating hash: key -> cluster_id, value -> array of simulation_ids
  def grouping_hash(data, number_of_subclusters)
    data_hash = {}
    for counter in 1..(number_of_subclusters.to_i)
      data_hash[counter] = data.select{ |k, v| v == counter }.keys
    end
    data_hash
  end


  ##
  # create second level chart data (sublcasters)
  # from 1 level gather sim_id and then create hash: level1 => {level2=>sim_ids}

  def create_subclusters(simulation_ind, subcluster,cluster)
    moes = Array(parameters["array"])
    hash = {}
    subcluster_size = 0
    previous_divide_subclust = []
    cluster.keys.each  do |subclust_indx|
      hash_sub = {}

      if subcluster[subclust_indx].length >= parameters[:subclusters].to_i
        groped_by_moes = {}

        # create hash {moe_name => [array of values]} it have only for those simulations which are in this cluster
        subcluster[subclust_indx].map do |row|
          row.each_with_index do |moe,ind|
            groped_by_moes[moes[ind]].kind_of?(Array)? groped_by_moes[moes[ind]].push(moe) :  groped_by_moes[moes[ind]] = [moe]
          end

        end
        #assign data in R
        groped_by_moes.each do |k,v|
          R.assign(k , v)
        end

        R.eval <<EOF
          hdata <- kmeans(data.frame(#{moes.join(",")}),#{parameters[:subclusters]})
          subclusters <- hdata$cluster
EOF
        to_merge = R.pull "subclusters"
        if to_merge != previous_divide_subclust
          # iterating from last number node in previus subclaster
          # to_merge is from zero but simulation_ind continues from the last
          for counter in subcluster_size..(subcluster_size+to_merge.count()-1)
            hash_sub[simulation_ind[counter]] = to_merge[counter-subcluster_size]
          end
          # adding how many simulations pass already
          subcluster_size += to_merge.count()
          previous_divide_subclust = to_merge
        else
          subcluster_size += subcluster[subclust_indx].length
        end
      else
        subcluster_size += subcluster[subclust_indx].length

      end
      hash[subclust_indx] = hash_sub
    end

    hash

  end

  def create_data_result(with_index=true, with_params=false, with_moes=true)
    moes = Array(parameters["array"])
    data_array=[]
    simulation_ind = []

    query_fields = {_id: 0}
    query_fields[:index] = 1 if with_index
    query_fields[:result] = 1 if with_moes

    @experiment.simulation_runs.where(
        {is_done: true, is_error: {'$exists' => false}},
        {fields: query_fields}
    ).each do |simulation_run|
      line = []
      line.push(simulation_run.index) if with_index
      simulation_ind << simulation_run.index
      moes_list =[]
      moes.map { |moe_name|
        moes_list.push(simulation_run.result[moe_name] || '') } if with_moes
      line << moes_list
      data_array << line
    end

    return simulation_ind, data_array
  end

end