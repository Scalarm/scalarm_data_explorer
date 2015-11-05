require 'minitest/autorun'
require 'test_helper'
require 'mocha'

class ThreeDTest < MiniTest::Test
  def setup
    Utils.require_plugin('three_d')
    @three_d = ThreeD.new

    @arguments = 'parameter1,parameter2,product'
    @arguments_ids = @arguments.split(',')

    @simulation_run = mock 'simulation_run'
    @simulation_run.stubs(:values).returns('1,2,3')

    @simulation_run2 = mock 'simulation_run2' do
      stubs(:values).returns('4,5,6')
    end

    @simulation_runs = [@simulation_run, @simulation_run2]



    # @simulation_runs = mock 'simulation_runs'
    # @simulation_runs.stubs(:first).returns(@simulation_run)
  end

  def test_get_3d
    @simulation_runs.stubs(:map).returns([{:arguments=>{"parameter1"=>0.0, "parameter2"=>8.0}, :result=>{"product"=>0.0}}, {:arguments=>{"parameter1"=>2.0, "parameter2"=>7.0}, :result=>{"product"=>14.0}}])
    @arguments_ids.stubs(:index).with('parameter1').returns(true)
    @arguments_ids.stubs(:index).with('parameter2').returns(true)
    @arguments_ids.stubs(:index).with('product').returns(false)
    assert_equal [[0.0, 8.0, 0.0], [2.0, 7.0, 14.0]], @three_d.get3d('parameter1', 'parameter2', 'product', @simulation_runs, @arguments_ids)
    assert_equal [], @three_d.get3d('parameter1', 'parameter2', 'product', [], @arguments_ids)
  end

  def test_get_points
    data_sim = {:arguments=>{"parameter1"=>1, "parameter2"=>2}, :result=>{"product"=>3}}
    @arguments_ids.stubs(:index).with('parameter1').returns(true)
    assert_equal [[1]], @three_d.get_points(data_sim, 'parameter1', @arguments_ids, [], -1)
    assert_equal [[2,1]], @three_d.get_points(data_sim, 'parameter1', @arguments_ids, [[2]], 0)
    assert_equal [[2],[3,1]], @three_d.get_points(data_sim, 'parameter1', @arguments_ids, [[2],[3]], 1)
    @arguments_ids.stubs(:index).with('parameter2').returns(true)
    assert_equal [[2],[2]], @three_d.get_points(data_sim, 'parameter2', @arguments_ids, [[2]], -1)
  end
end