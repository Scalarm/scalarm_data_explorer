require 'minitest/autorun'
require 'test_helper'
require 'mocha'

class BoxplotTest < MiniTest::Test

  def setup
    Utils.require_plugin('boxplot')
    @boxplot = Boxplot.new


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
    @simulation_runs = mock 'simulation runs'
    @simulation_runs.stubs(:to_a).returns(@simulation_runs_array)
    @simulation_runs.stubs(:where).returns(@simulation_runs)

    @experiment = mock 'experiment'
    @experiment.stubs(:simulation_runs).returns(@simulation_runs)
  end


  def test_get_boxplot_data
    assert_equal ({:data=>[[0.5, 1.25, 1.5, 1.75, 2.5], [3.0, 3.0, 3.0, 3.0, 3.0], [5.0, 5.0, 5.0, 5.0, 5.0]], :categories=>[0.0, 2.0, 4.0], :outliers=>[], :mean=>2.75}), @boxplot.get_boxplot_data(@experiment, 'parameter1', 'parameter2')
  end
  #
  # def test_get_parameters
  #   assert_equal ({:arguments=>{'parameter1' =>0.0, 'parameter2' =>1.0}, :result=>{'product' =>0.0}}), @lindev.get_parameters(@simulation_run, @arguments_ids)
  #   assert_equal ({}), @lindev.get_parameters(@simulation_run, [])[:arguments]
  #   assert_equal ({}), @lindev.get_parameters(@simulation_run_empty, @arguments_ids)[:result]
  # end
  #
  # def test_get_values_and_std_dev
  #   assert_equal [[0.0, 5.0], [2.0, 1.0]] , @lindev.get_values_and_std_dev({0=>[2,4,6,8],2=>[1]})[0]
  #   refute_nil @lindev.get_values_and_std_dev({0=>[2,4,6,8],2=>[1]})[1]
  #   assert_equal [] , @lindev.get_values_and_std_dev({})[0]
  # end
  #
  def test_prepare_boxplot_chart_content
    @boxplot.stubs(:parameters).returns({"param_x"=>"parameter1", "param_y"=>"parameter2", "chart_id"=>"0"})
    parameter1 = @boxplot.parameters['param_x']
    parameter2 = @boxplot.parameters['param_y']
    assert_includes "<script>(function() { \nvar i=0;\nboxplot_main(i, \"#{parameter1}\", \"#{parameter2}\", data, categories, outliers, mean);\n})();</script>", @boxplot.prepare_boxplot_chart_content({})
  end

  def test_handler
    @boxplot.stubs(:parameters).returns({"param_x"=>"parameter1", "param_y"=>"parameter2", "chart_id"=>"0", "id"=>"boxplot"})
    @boxplot.stubs(:experiment).returns(@experiment)
    assert @boxplot.handler.include?('<script>')
  end

  def test_get_parameters
    assert_equal ({:arguments=>{'parameter1' =>0.0, 'parameter2' =>1.0}, :result=>{'product' =>0.0}}), @boxplot.get_parameters(@simulation_run, @arguments_ids)
    assert_equal ({}), @boxplot.get_parameters(@simulation_run, [])[:arguments]
    assert_equal ({}), @boxplot.get_parameters(@simulation_run_empty, @arguments_ids)[:result]
  end

  def test_find_outliers
    assert_equal [], @boxplot.find_outliers([1,2,3], 1, 1, 3)
    assert_equal [[1,-3], [1,7]], @boxplot.find_outliers([-3,2,7], 1, 1, 3)
  end

  def test_get_statistics
    assert_equal ({"whisker_bottom"=>-1.0, "q1"=>2.0, "med"=>3.0, "q3"=>4.0, "whisker_upper"=>7.0}), @boxplot.get_statictics([1,2,3,4,5])
    assert_equal ({"whisker_bottom"=>1.0, "q1"=>1.0, "med"=>1.0, "q3"=>1.0, "whisker_upper"=>1.0}), @boxplot.get_statictics([1])
  end

  def test_param_ids_with_less_than_n_values
    assert_equal ([]), Utils.param_ids_with_less_than_n_values(@experiment, 0)
    assert_equal (["product"]), Utils.param_ids_with_less_than_n_values(@experiment, 1)
    assert_equal (["parameter1", "product"]), Utils.param_ids_with_less_than_n_values(@experiment, 3)
    assert_equal (["parameter1", "parameter2", "product"]), Utils.param_ids_with_less_than_n_values(@experiment, 8)
  end
end