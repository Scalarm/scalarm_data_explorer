require 'minitest/autorun'
require 'test_helper'
require 'mocha'
require 'db_helper'

class ChartInstancesControllerTest < ActionController::TestCase

  def setup
    stub_authentication
    experiment1_id = BSON::ObjectId.new

    @simulation_run = mock do
      stubs(:result).returns('1,2,3')
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


  test "should get show success" do
    get :show, id: 'dendrogram', experiment_id: @experiment.id.to_s, chart_id: '0', output: 'product', stand_alone: 'true'
    assert_response :success
  end

  # there should be section with id like name of method in id
  test "should load appropriate type of chart" do
    get :show, id: 'dendrogram', experiment_id: @experiment.id.to_s, chart_id: '0', output: 'product', stand_alone: 'true'
    assert_equal 'dendrogram_chart_form', response.body[/\<section\s+class='panel\s+radius\s+plot'\s+id='(.*?)'>/,1]
  end

  test "should load css if stand_alone = true" do
    get :show, id: 'dendrogram', experiment_id: @experiment.id.to_s, chart_id: '0', output: 'product', stand_alone: 'true'

    assert_response :success
    assert response.body.include?('/assets/application')
  end

  test "should not load css if stand_alone = false" do
    get :show, id: 'dendrogram', experiment_id: @experiment.id.to_s, chart_id: '0', output: 'product', stand_alone: 'false'

    assert_response :success
    assert (not response.body.include? '/assets/application')
  end

  test "should not load css if stand_alone is not defined" do
    get :show, id: 'dendrogram', experiment_id: @experiment.id.to_s, chart_id: '0', output: 'product'

    assert_response :success
    assert (not response.body.include? '/assets/application')
  end
end
