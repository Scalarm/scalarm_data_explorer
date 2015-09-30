require 'minitest/autorun'
require 'test_helper'
require 'mocha'

class InteractionTest < MiniTest::Test

  def setup
    Utils.require_plugin('interaction')
    @interaction = Interaction.new

    @arguments = 'parameter1,parameter2'
    @arguments_ids = @arguments.split(',')

    @simulation_run = mock do
      stubs(:values).returns('0,7')
      stubs(:result).returns({'product' =>0})
    end

    @simulation_run2 = mock do
      stubs(:values).returns('0,8')
      stubs(:result).returns({'product' =>0})
    end

    @simulation_run3 = mock do
      stubs(:values).returns('2,7')
      stubs(:result).returns({'product' =>14})
    end

    @simulation_run4 = mock do
      stubs(:values).returns('2,8')
      stubs(:result).returns({'product' =>16})
    end

    @simulation_run5 = mock do
      stubs(:values).returns('4,7')
      stubs(:result).returns({'product' =>28})
    end

    @simulation_run6 = mock do
      stubs(:values).returns('4,8')
      stubs(:result).returns({'product' =>32})
    end

    @simulation_run_empty = mock do
      stubs(:result).returns({})
      stubs(:arguments).returns(@arguments)
      stubs(:values).returns('4,5')
    end

    @simulation_runs_array = [@simulation_run, @simulation_run2, @simulation_run3, @simulation_run4, @simulation_run5, @simulation_run6]
    @simulation_runs_array.each do |simulation_run|
       simulation_run.stubs(:arguments).returns(@arguments)
    end

    @simulation_runs = mock
    @simulation_runs.stubs(:to_a).returns(@simulation_runs_array)

    @experiment = mock 'experiment'
    @experiment.stubs(:simulation_runs).returns(@simulation_runs)
  end

  def test_get_interaction
    assert_equal ({'parameter1' =>{:domain=>[0.0, 4.0]}, 'parameter2' =>{:domain=>[7.0, 8.0]}, :effects=>[0.0, 0.0, 28.0, 32.0]}), @interaction.get_interaction(@experiment, 'parameter1', 'parameter2', 'product')
  end

  def test_get_parameters
    assert_equal ({:arguments=>{'parameter1' =>0.0, 'parameter2' =>7.0}, :result=>{'product' =>0.0}}), @interaction.get_parameters(@simulation_run, @arguments_ids, {})
    assert_equal ({}), @interaction.get_parameters(@simulation_run, [], {})[:arguments]
    assert_equal ({}), @interaction.get_parameters(@simulation_run_empty, @arguments_ids, {})[:result]
  end

  def test_prepare_interaction_chart_content
    @interaction.stubs(:parameters).returns({'param_x' => 'parameter1', 'param_y' => 'parameter2', 'chart_id' => '0'})
    parameter1 = @interaction.parameters['param_x']
    parameter2 = @interaction.parameters['param_y']
    assert_includes "<script>(function() { \nvar i=0;\nvar data = [];\ninteraction_main(i, \"#{parameter1}\", \"#{parameter2}\", data);\n})();</script>", @interaction.prepare_interaction_chart_content([])
  end

  def test_handler
    @interaction.stubs(:parameters).returns({'param_x' => 'parameter1', 'param_y' => 'parameter2', 'chart_id' => '0', 'id' => 'interaction'})
    @interaction.stubs(:experiment).returns(@experiment)
    assert @interaction.handler.include?('<script>')
  end
end

