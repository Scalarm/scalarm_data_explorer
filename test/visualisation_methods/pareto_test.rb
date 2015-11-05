require 'minitest/autorun'
require 'test_helper'
require 'mocha'

class ParetoTest < MiniTest::Test

  def setup
    Utils.require_plugin('pareto')
    @pareto = Pareto.new

    @arguments = 'parameter1,parameter2'
    @arguments_ids = @arguments.split(',')

    @simulation_runs = mock 'simulation_runs'

    @simulation_run = mock 'simulation_run'
    @simulation_run.stubs(:values).returns('4,5')
    @simulation_run.stubs(:result).returns({'moe' =>5})
    @simulation_run.stubs(:arguments).returns('parameter1,parameter2')

    @simulation_run2 = mock
    @simulation_run2.stubs(:values).returns('6,7')
    @simulation_run2.stubs(:result).returns({'moe' =>6})
    @simulation_run2.stubs(:arguments).returns(@arguments)

    @simulation_run3 = mock 'simulation_run'
    @simulation_run3.stubs(:values).returns('8,9')
    @simulation_run3.stubs(:result).returns({'moe' =>10})
    @simulation_run3.stubs(:arguments).returns('parameter1,parameter2')
    @simulation_runs_array = [@simulation_run, @simulation_run2, @simulation_run3]

    @simulation_runs_array.each do |simulation_run|
      simulation_run.stubs(:arguments).returns(@arguments)
    end

    @simulation_runs.stubs(:to_a).returns(@simulation_runs_array)

    @experiment = mock 'experiment'
    @experiment.stubs(:simulation_runs).returns(@simulation_runs)


    @pareto.stubs(:experiment).returns(@experiment)
  end

  def test_get_pareto_data
    assert_equal [{:name=>"parameter1", :value=>5.0}, {:name=> 'parameter2', :value=>5.0}], @pareto.get_pareto_data('moe')
  end

  def test_get_chart_content_for_argument
    data = []
    maxes = {'parameter1' =>8.0, 'parameter2' =>9.0}
    mins = {'parameter1' =>4.0, 'parameter2' =>5.0}
    params = {'parameter1' =>[4.0, 8.0], 'parameter2' =>[5.0, 9.0]}
    simulation_runs = [{:arguments=>{'parameter1' =>4.0, 'parameter2' =>5.0}, :result=>5.0}, {:arguments=>{'parameter1' =>8.0, 'parameter2' =>9.0}, :result=>2.0}]

    assert_equal 3.0, @pareto.get_chart_content_for_argument('parameter1', data, maxes, mins, params, simulation_runs)[0][:value]

    params = {'parameter1' =>[4.0, 8.0, 8.0], 'parameter2' =>[5.0, 2,0, 9.0]}
    simulation_runs.push({:arguments=>{'parameter1' =>8.0, 'parameter2' =>2.0}, :result=>3.0})

    assert_equal 3.0, @pareto.get_chart_content_for_argument('parameter1', data, maxes, mins, params, simulation_runs)[0][:value]
  end

  def test_handler
    @pareto.stubs(:parameters).returns({'output' => 'moe', 'chart_id' => '0', 'id' => 'pareto'})
    @pareto.stubs(:experiment).returns(@experiment)
    assert @pareto.handler.include?('<script>')
  end

  def test_prepare_pareto_chart_content
    @pareto.stubs(:parameters).returns({'output' =>'moe', 'chart_id' => '0', 'id' => 'pareto'})
    assert_includes "<script>(function() { \nvar i=0;\nvar data = [];\npareto_main(i, data);\n})();</script>", @pareto.prepare_pareto_chart_content([])
  end

  def test_get_parameters
    simulation_run_empty = mock
    simulation_run_empty.stubs(:result).returns({})
    simulation_run_empty.stubs(:values).returns('8,9')
    simulation_run_empty.stubs(:arguments).returns('parameter1,parameter2')

    assert_equal ({:arguments=>{'parameter1' =>4.0, 'parameter2' =>5.0}, :result=>5.0}), @pareto.get_parameters(@simulation_run, @arguments_ids, {}, 'moe')
    assert_equal ({}), @pareto.get_parameters(@simulation_run,  {}, {}, 'moe')[:arguments]
    assert_equal ({}), @pareto.get_parameters(simulation_run_empty, @arguments_ids, {}, 'moe')[:result]
  end
end
