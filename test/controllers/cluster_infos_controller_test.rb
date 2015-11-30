require 'minitest/autorun'
require 'test_helper'
require 'mocha'

class ClusterInfosControllerTest < ActionController::TestCase
  params = ["parameter1", "parameter2", "product", "product_2"]
  data = [[15.0, -174.0, 15, 21], [0.0, -18.0, 89, 1], [10.0, -5.0, 0, 15], [65.0, 8.0, 34, 1], [120.0, 99.0, 0, 91]]

  def setup
    stub_authentication
    experiment1_id = BSON::ObjectId.new

    @simulation_run = mock do
      stubs(:result).returns({result: {product: 3618.0, product_2: 3412.0}})
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
    ClusterInfos.any_instance.expects(:create_data_result).returns([params, data])
    get :show, id: @experiment.id.to_s, simulations: "1,2,3,4,5", using_em: 'false'
    assert_response :success
  end


  test "Should return json with status ok" do
    ClusterInfos.any_instance.expects(:create_data_result).returns([params, data])
    get :show, format: :json, id: @experiment.id.to_s, simulations: "1,2,3,4,5", using_em: 'false'
    assert_response :success
    assert_includes(response.body, '"status":"ok"', response.body)
  end


  test "Should pass with status ok when is less parameters than in data" do
    ClusterInfos.any_instance.expects(:create_data_result).returns([["parameter1", "parameter2"], data])
    get :show, format: :json, id: @experiment.id.to_s, simulations: "1,2,3,4,5", using_em: 'false'
    assert_response :success
    assert_includes(response.body, '"status":"ok"', response.body)
  end


  test "Should no pass when is more parameters than in data" do
    ClusterInfos.any_instance.expects(:create_data_result).returns([["parameter1", "parameter2", "product", "product_2", "Ala"], data])
    get :show, format: :json, id: @experiment.id.to_s, simulations: "1,2,3,4,5", using_em: 'false'
    assert_response :internal_server_error, "Response should be error, but it is: #{response.body}"
    assert_includes(response.body, '"status":"error"', response.body)
  end


  test "Should be error when wrong simulation ids are given" do
    get :show, id: @experiment.id.to_s, simulations: "Ala,1,2,3", using_em: 'false'
    assert_response :precondition_failed, "Response should be error, but it is: #{response.body}"
  end


  test "Should be error with no experiment id" do
    get :show, id: "No experiment ", simulations: "1,2,3", using_em: 'false'
    assert_response :precondition_failed, "Response should be error, but it is: #{response.body}"
  end


  test "Should be error with no experiment id (JSON)" do
    get :show, format: :json, id: "No experiment ", using_em: 'false'
    assert_response :precondition_failed, "Response should be error, but it is: #{response.body}"
  end


  test "Should return error when no simulation ids" do
    get :show, id: @experiment.id.to_s, using_em: 'false'
    assert_response :precondition_failed, "Response should be error, but it is: #{response.body}"
  end
end