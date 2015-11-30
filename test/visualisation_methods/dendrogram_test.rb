require 'minitest/autorun'
require 'test_helper'
require 'mocha'

class DendrogramTest < MiniTest::Test

  def setup
    Utils.require_plugin('dendrogram')
    @dendrogram = Dendrogram.new
    @dendrogram.stubs(:parameters).returns({'array' =>['moe']})

    @simulation_run = mock do
      stubs(:values).returns('0,1')
      stubs(:index).returns(55)
      stubs(:result).returns({'moe' =>2})
      stubs(:each).returns(@simulation_run)
    end

    @simulation_run2 = mock do
      stubs(:values).returns('3,4')
      stubs(:index).returns(56)
      stubs(:result).returns({'moe' =>6})
      stubs(:each).returns(@empty_simulation_run)
    end

    @simulation_runs = mock 'simulation runs'
    @simulation_runs.stubs(:where).returns([@simulation_run, @simulation_run2])
    @simulation_runs.stubs(:to_a).returns([@simulation_run, @simulation_run2])

    @experiment = mock 'experiment'
    @experiment.stubs(:get_parameter_ids).returns(['parameter1', 'parameter2'])
    @experiment.stubs(:simulation_runs).returns(@simulation_runs)
    @experiment.stubs(:id).returns(BSON::ObjectId.new)

    @dendrogram.stubs(:experiment).returns(@experiment)
  end

  def test_handler
    @dendrogram.stubs(:parameters).returns({'array' =>['moe'], 'chart_id' => '0', 'id' => 'dendrogram'})
    @dendrogram.stubs(:experiment).returns(@experiment)
    assert @dendrogram.handler.include?('<script>')
  end

  def test_get_data_for_dendrogram
    assert_equal "{\"id\":\"1\",\"children\":[{\"id\":\"1\"},{\"id\":\"2\"}]}", @dendrogram.get_data_for_dendrogram
  end

  def test_get_simulations_by_cluster
    assert_equal '2, 3', @dendrogram.get_simulations_by_cluster({'1'=>[-2,-3]}, 1)
    assert_equal '2, 5, 6', @dendrogram.get_simulations_by_cluster({'1'=>[-2,3], '2'=>[-4,-5], '3'=>[-5,-6]}, 1)
    assert_equal nil, @dendrogram.get_simulations_by_cluster({'1'=>[-2,-3]}, 5)
    assert_equal nil, @dendrogram.get_simulations_by_cluster({}, 5)
  end

  def test_create_hash
    assert_equal ({'id'=>1, 'depth'=>0, 'children'=>[{'id'=>2}, {'id'=>3}]}), @dendrogram.create_hash({'1'=>[-2,-3]}, 1, 0)
    assert_equal nil, @dendrogram.create_hash({'1'=>[-2,-3]}, 3, 0)
    assert_equal nil, @dendrogram.create_hash({'1'=>[-2,-3]}, 4, 0)
  end

  def test_get_the_best_depth
    assert_equal 1, @dendrogram.get_the_best_depth({'1'=>[-2,-3]}, 1, ({'id'=>1, 'depth'=>0, 'children'=>[{'id'=>2}, {'id'=>3}]}))
    data = {'1'=>[-2,3], '3'=>[-1,4], '4'=>[5,6], '5'=>[-7,-8], '6'=>[-9,-10]}
    assert_equal 4, @dendrogram.get_the_best_depth(data, 1, @dendrogram.create_hash(data, 1, 0))
  end

  def test_get_max_depth
    data = {'1'=>[-2,3], '3'=>[-1,4], '4'=>[5,6], '5'=>[-7,-8], '6'=>[-9,-10]}
    assert_equal 4, @dendrogram.get_max_depth(data, 1, 0)
    assert_equal 2, @dendrogram.get_max_depth(data, 4, 0)
    assert_equal 10, @dendrogram.get_max_depth(data, 1, 6)

    data = {'1'=>[-2,-3]}
    assert_equal 1, @dendrogram.get_max_depth(data, 1, 0)
    assert_equal nil, @dendrogram.get_max_depth(data, 2, 0)

    assert_equal nil, @dendrogram.get_max_depth({}, 1, 0)
  end

  def test_count_of_leafs
    hash = @dendrogram.create_hash({'1'=>[-2,3], '3'=>[-1,4], '4'=>[5,6], '5'=>[-7,-8], '6'=>[-9,-10]}, 1, 0)
    assert_equal 1, @dendrogram.count_of_leafs(hash, 0, 0)
    assert_equal 2, @dendrogram.count_of_leafs(hash, 1, 0)
    assert_equal 4, @dendrogram.count_of_leafs(hash, 3, 0)
    assert_equal 6, @dendrogram.count_of_leafs(hash, 4, 0)
    assert_equal 6, @dendrogram.count_of_leafs(hash, 10, 0)
  end

  def test_create_json_max_depth
    data = {'1'=>[-2,3], '3'=>[-4,-5]}
    assert_equal "{\"id\":\"1\",\"children\":[{\"id\":\"3\",\"children\":[{\"id\":\"4\"},{\"id\":\"5\"}]},{\"id\":\"2\"}]}", @dendrogram.create_json_max_depth(data, 1, 0, 2)
    assert_equal "{\"id\":\"1\",\"children\":[{\"id\":\"cl 3\",\"simulations\":\"4, 5\"},{\"id\":\"2\"}]}", @dendrogram.create_json_max_depth(data, 1, 0, 0)
  end

  def test_create_result_csv
    en = @dendrogram.create_result_csv[42]
    assert_equal 'simulation_index,parameter1,parameter2,moe', @dendrogram.create_result_csv.split(en)[0]
    assert_equal 3, @dendrogram.create_result_csv.split(en).length
  end

  def test_create_line_csv
    moes = Array(@dendrogram.parameters["array"])
    assert_equal [55, "0", "1", 2], @dendrogram.create_line_csv(@simulation_run, moes)
  end


end