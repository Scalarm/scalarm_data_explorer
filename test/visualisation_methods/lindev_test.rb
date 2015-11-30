require 'minitest/autorun'
require 'test_helper'
require 'mocha'

class LindevTest < MiniTest::Test

  def setup
    Utils.require_plugin('lindev')
    @lindev = Lindev.new


    @arguments = 'parameter1,parameter2'
    @arguments_ids = @arguments.split(',')

    @simulation_run = mock do
      stubs(:values).returns('0,1')
      stubs(:arguments).returns(@arguments)
    end

    @simulation_run2 = mock do
      stubs(:values).returns('2,3')
    end

    @simulation_run3 = mock do
      stubs(:values).returns('0,2')
    end

    @simulation_run_empty = mock do
      stubs(:result).returns({})
      stubs(:arguments).returns(@arguments)
      stubs(:values).returns('4,5')
    end

    @simulation_runs_array = [@simulation_run, @simulation_run2, @simulation_run3]
    @simulation_runs_array.each do |simulation_run|
      simulation_run.stubs(:result).returns({'product' =>0})
      simulation_run.stubs(:arguments).returns(@arguments)
    end
    @simulation_runs_array.push(@simulation_run_empty)

    # inside the bloc mock do can not use instance variable
    @simulation_runs = mock
    @simulation_runs.stubs(:to_a).returns(@simulation_runs_array)

    @experiment = mock 'experiment'
    @experiment.stubs(:simulation_runs).returns(@simulation_runs)
  end


  def test_get_line_dev_data
    assert_equal [[[0.0, 1.5], [2.0, 3.0], [4.0, 5.0]], [[0.0, 1.0, 2.0], [2.0, 3.0, 3.0], [4.0, 5.0, 5.0]]], @lindev.get_line_dev_data(@experiment, 'parameter1', 'parameter2')
    assert_equal 0.0, @lindev.get_line_dev_data(@experiment, 'parameter1', 'parameter3')[0][0][0]
  end

  def test_get_parameters
    assert_equal ({:arguments=>{'parameter1' =>0.0, 'parameter2' =>1.0}, :result=>{'product' =>0.0}}), @lindev.get_parameters(@simulation_run, @arguments_ids)
    assert_equal ({}), @lindev.get_parameters(@simulation_run, [])[:arguments]
    assert_equal ({}), @lindev.get_parameters(@simulation_run_empty, @arguments_ids)[:result]
  end

  def test_get_values_and_std_dev
    assert_equal [[0.0, 5.0], [2.0, 1.0]] , @lindev.get_values_and_std_dev({0=>[2,4,6,8],2=>[1]})[0]
    refute_nil @lindev.get_values_and_std_dev({0=>[2,4,6,8],2=>[1]})[1]
    assert_equal [] , @lindev.get_values_and_std_dev({})[0]
  end

  def test_prepare_lindev_chart_content
    @lindev.stubs(:parameters).returns({"param_x"=>"parameter1", "param_y"=>"parameter2", "chart_id"=>"0"})
    parameter1 = @lindev.parameters['param_x']
    parameter2 = @lindev.parameters['param_y']
    assert_includes "<script>(function() { \nvar i=0;\nvar data = [];\nlindev_main(i, \"#{parameter1}\", \"#{parameter2}\", data);\n})();</script>", @lindev.prepare_lindev_chart_content([])
  end

  def test_handler
    @lindev.stubs(:parameters).returns({"param_x"=>"parameter1", "param_y"=>"parameter2", "chart_id"=>"0", "id"=>"lindev"})
    @lindev.stubs(:experiment).returns(@experiment)
    assert @lindev.handler.include?('<script>')
  end
end