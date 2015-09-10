require 'minitest/autorun'
require 'test_helper'
require 'mocha'
require 'db_helper'


class ChartInstancesControllerTest < ActionController::TestCase

  def setup
    stub_authentication
  end

  def teardown
    super

  end


  test "should get show appropriate chart_id" do
    experiment1_id = BSON::ObjectId.new
    ChartInstancesController.any_instance.expects(:require_plugin)


    simulation_run = mock do
      stubs(:result).returns('1,2,3')
    end

    simulation_runs = mock do
      stubs(:where).returns([simulation_run])
    end

    experiment = mock 'experiment' do
      stubs(:id).returns(experiment1_id)
      stubs(:start_at).returns(Time.now)
      stubs(:completed?).returns(true)
      stubs(:simulation_runs).returns(simulation_runs)
      stubs(:get_parameter_ids).returns(['a'])
    end

    visible_experiments = mock do
      stubs(:find_by_id).returns(experiment)
    end

    ChartInstancesController.any_instance.expects(:generate_content_with_plugin).with('dendrogram', experiment, includes('chart_id' , 'output')).returns('<script>alert(\'1\')</script>')
    Scalarm::Database::Model::Experiment.stubs(:visible_to).with(@user).returns(visible_experiments)

    get :show, id: 'dendrogram', experiment_id: experiment.id.to_s, chart_id: '0', output: 'product', using_em: 'false'

    assert_response :success
    assert_equal 'dendrogram_chart_form', response.body[/\<section class='panel radius plot' id='(.*?)'>/,1]
    assert_includes response.body, '/assets/application.css', nil



  end

  test "should not apply application.js" do
    experiment1_id = BSON::ObjectId.new
    ChartInstancesController.any_instance.expects(:require_plugin)


    simulation_run = mock do
      stubs(:result).returns('1,2,3')
    end

    simulation_runs = mock do
      stubs(:where).returns([simulation_run])
    end

    experiment = mock 'experiment' do
      stubs(:id).returns(experiment1_id)
      stubs(:start_at).returns(Time.now)
      stubs(:completed?).returns(true)
      stubs(:simulation_runs).returns(simulation_runs)
      stubs(:get_parameter_ids).returns(['a'])
    end

    visible_experiments = mock do
      stubs(:find_by_id).returns(experiment)
    end

    ChartInstancesController.any_instance.expects(:generate_content_with_plugin).with('dendrogram', experiment, includes('chart_id' , 'output')).returns('<script>alert(\'1\')</script>')
    Scalarm::Database::Model::Experiment.stubs(:visible_to).with(@user).returns(visible_experiments)

    get :show, id: 'dendrogram', experiment_id: experiment.id.to_s, chart_id: '0', output: 'product', using_em: 'true'
    refute_includes response.body, '/assets/application.css', nil
  end

  test "should not apply application.js if using_em is not defined" do
    experiment1_id = BSON::ObjectId.new
    ChartInstancesController.any_instance.expects(:require_plugin)


    simulation_run = mock do
      stubs(:result).returns('1,2,3')
    end

    simulation_runs = mock do
      stubs(:where).returns([simulation_run])
    end

    experiment = mock 'experiment' do
      stubs(:id).returns(experiment1_id)
      stubs(:start_at).returns(Time.now)
      stubs(:completed?).returns(true)
      stubs(:simulation_runs).returns(simulation_runs)
      stubs(:get_parameter_ids).returns(['a'])
    end

    visible_experiments = mock do
      stubs(:find_by_id).returns(experiment)
    end

    ChartInstancesController.any_instance.expects(:generate_content_with_plugin).with('lindev', experiment, includes('chart_id' , 'output')).returns('<script>alert(\'1\')</script>')
    Scalarm::Database::Model::Experiment.stubs(:visible_to).with(@user).returns(visible_experiments)

    get :show, id: 'lindev', experiment_id: experiment.id.to_s, chart_id: '0', output: 'product'
    refute_includes response.body, '/assets/application.css', nil
  end






end
