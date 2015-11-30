require 'minitest/autorun'
require 'test_helper'
require 'mocha'

class ModalsControllerTest < ActionController::TestCase

  def setup
    stub_authentication
    experiment1_id = BSON::ObjectId.new

    @simulation_run = mock do
      stubs(:result).returns({result: {product: 3618.0}})
      stubs(:is_done).returns(true)
    end

    # inside the bloc mock do can not use instance variable
    @simulation_runs = mock
    @simulation_runs.stubs(:where).returns([@simulation_run])

    @experiment = mock 'experiment' do
      stubs(:id).returns(experiment1_id)
      stubs(:start_at).returns(Time.now)
      stubs(:completed?).returns(true)
      stubs(:get_parameter_ids).returns(['a'])
    end
    @experiment.stubs(:simulation_runs).returns(@simulation_runs)

    @visible_experiments = mock
    @visible_experiments.stubs(:find_by_id).returns(@experiment)

    Scalarm::Database::Model::Experiment.stubs(:visible_to).with(@user).returns(@visible_experiments)
  end

  def teardown
    super

  end


  test "Should be success" do
    get :show, id: 'lindev', experiment_id: @experiment.id.to_s, using_em: 'false'
    assert_response :success
  end


  test "Should report error with message: Wrong Chart name" do
    get :show, id: 'Ala', experiment_id: @experiment.id.to_s, using_em: 'false'
    assert_response 412, "Response should be error, but it is: #{response.body}"
  end


  test "Should render modal content" do
    pareto_content = "<section class='panel radius analysis-chart' id='pareto_charts_form'>"
    pareto_header = "<h3 class='subheader'>Pareto chart</h3>"
    get :show, id: 'pareto', experiment_id: @experiment.id.to_s, using_em: 'false'
    assert_includes(response.body, pareto_content, "Not valid modal content")
    assert_includes(response.body, pareto_header, "Not valid modal header")

  end


  test "Should render valid chart draw function" do
    pareto_function="window.pareto_main = function (i, data)"
    get :show, id: 'pareto', experiment_id: @experiment.id.to_s, using_em: 'false'
    assert_includes(response.body, pareto_function, "Not valid chart draw function")
  end


  test "Should render code from valid catalog" do
    assert_generates '/modals/three_d',
                     {:controller => 'modals', :action => 'show', :id => 'three_d', :experiment_id => @experiment.id.to_s},
                     {},
                     {:experiment_id => @experiment.id.to_s}
  end
end