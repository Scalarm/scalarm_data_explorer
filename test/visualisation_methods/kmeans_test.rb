require 'minitest/autorun'
require 'test_helper'
require 'mocha'

class KmeansTest < MiniTest::Test

  def setup
    Utils.require_plugin('kmeans')
    @kmeans = Kmeans.new
    @kmeans.stubs(:parameters).returns({'array' =>['moe']})

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

    @empty_simulation_run = mock 'empty simulation run' do
      stubs(:values).returns('3,4')
      stubs(:index).returns(57)
      stubs(:result).returns({})
      stubs(:each).returns(@empty_simulation_run)
    end

    @simulation_runs = mock
    @simulation_runs.stubs(:where).returns([@simulation_run, @simulation_run2])

    @experiment = mock 'experiment'
    @experiment.stubs(:get_parameter_ids).returns(['parameter1', 'parameter2'])
    @experiment.stubs(:simulation_runs).returns(@simulation_runs)
    @experiment.stubs(:id).returns(BSON::ObjectId.new)

    @kmeans.stubs(:experiment).returns(@experiment)
  end

  def test_create_data_result
    assert_equal [[55, 56], [[55, [2]], [56, [6]]]], @kmeans.create_data_result(@experiment)
  end

  def test_create_header
    assert_equal ["moe"], @kmeans.create_header
  end

  def test_grouping_hash
    assert_equal ({1=>[], 2=>[1,2], 3=>[]}), @kmeans.grouping_hash({1 => 2, 2 => 2}, 3)
    assert_equal ({1=>[]}), @kmeans.grouping_hash({1 => 2, 2 => 2}, 1)
    assert_equal ({1=>[]}), @kmeans.grouping_hash({}, 1)
  end
end