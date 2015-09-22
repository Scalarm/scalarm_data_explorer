require 'minitest/autorun'
require 'test_helper'
require 'mocha'

class DendrogramTest < MiniTest::Test

  def setup
    Utils.require_plugin('dendrogram')
    @dendrogram = Dendrogram.new
  end

  def test_get_simulations_by_cluster
    assert_equal '2, 3', @dendrogram.get_simulations_by_cluster({'1'=>[-2,-3]}, 1)
    assert_equal '2, 5, 6', @dendrogram.get_simulations_by_cluster({'1'=>[-2,3], '2'=>[-4,-5], '3'=>[-5,-6]}, 1)
    assert_equal nil, @dendrogram.get_simulations_by_cluster({'1'=>[-2,-3]}, 5)
    assert_equal nil, @dendrogram.get_simulations_by_cluster({}, 5)
  end

  def test_create_hash
    assert_equal ({'id'=>1, 'depth'=>0, 'children'=>[{'id'=>2}, {'id'=>3}]}), @dendrogram.create_hash({'1'=>[-2,-3]}, 1, 0)
    # assert_equal ({'id'=>3, 'depth'=>0, 'children'=>nil}), @dendrogram.create_hash({'1'=>[-2,-3]}, 3, 0)
    assert_equal nil, @dendrogram.create_hash({'1'=>[-2,-3]}, 4, 0)
  end

  def test_get_the_best_depth
    # assert_equal 1, @dendrogram.get_the_best_depth({'1'=>[-2,-3]}, 1, ({'id'=>1, 'depth'=>0, 'children'=>[{'id'=>2}, {'id'=>3}]}))
    # assert_equal 1, @dendrogram.get_the_best_depth({'1'=>[-2,-3]}, 1, @dendrogram.create_hash({'1'=>[-2,-3]}, 1, 0))
    data = {'1'=>[-2,3], '3'=>[-1,4], '4'=>[5,6], '5'=>[-7,-8], '6'=>[-9,-10]}
    assert_equal 1, @dendrogram.get_the_best_depth(data, 1, @dendrogram.create_hash(data, 1, 0))
  #   trzeba sprawdzić get_max_depth
  end

end