require 'minitest/autorun'
require 'test_helper'
require 'mocha'

class InteractionTest < MiniTest::Test

  def setup
    Utils.require_plugin('interaction')
    @interaction = Interaction.new
  end

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

    # inside the bloc mock do can not use instance variable
    @simulation_runs = mock
    @simulation_runs.stubs(:to_a).returns(@simulation_runs_array)

    @experiment = mock 'experiment'
    @experiment.stubs(:simulation_runs).returns(@simulation_runs)
  end

  def test_get_interaction
    assert_equal ({"parameter1"=>{:domain=>[0.0, 4.0]}, "parameter2"=>{:domain=>[7.0, 8.0]}, :effects=>[0.0, 0.0, 28.0, 32.0]}), @interaction.get_interaction(@experiment, 'parameter1', 'parameter2', 'product')
  end

  def test_get_parameters
    assert_equal ({:arguments=>{"parameter1"=>0.0, "parameter2"=>7.0}, :result=>{"product"=>0.0}}), @interaction.get_parameters(@simulation_run, @arguments_ids, {})
    assert_equal ({}), @interaction.get_parameters(@simulation_run, [], {})[:arguments]
    assert_equal ({}), @interaction.get_parameters(@simulation_run_empty, @arguments_ids, {})[:result]
  end

  def test_add_to_proper_hash

  end




end