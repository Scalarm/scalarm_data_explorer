


require 'minitest/autorun'
require 'test_helper'
require 'mocha'
require 'db_helper'


class PanelsControllerTest < ActionController::TestCase
  include DBHelper

  def setup
    stub_authentication
  end

  def teardown
    super
  end


  test "should get show" do
=begin
    experiment1_id = BSON::ObjectId.new
    ApplicationController.any_instance.stubs(:load_experiment).returns([])

    experiment = mock 'experiment' do
      stubs(:id).returns(experiment1_id)
      stubs(:start_at).returns(Time.now)
      stubs(:completed?).returns(true)
    end
=end

    # require 'scalarm/database'
    #
    # experiment = Scalarm::Database::Model::Experiment.new(a: 1)
    # experiment.save
    # @experiment = Scalarm::Database::Model::Experiment.find_by_id(experiment.id)
    # get :show, id: experiment.id
    #
    # puts response.body
    # assert_response :success



    experiment1_id = BSON::ObjectId.new
    PanelsController.any_instance.stubs(:handle_panel_for_experiment)
    panels = Panels.new

    analysisMethodsConfig = AnalysisMethodsConfig.new
    analysisMethodsConfig.stubs(:get_groups).returns({})

    simulation_run = mock do
      stubs(:result).returns({'product'=>4})
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

    Scalarm::Database::Model::Experiment.stubs(:visible_to).with(@user).returns(visible_experiments)

    puts panels.groups




    get :index, id: experiment.id

    puts response.body


    assert_response :success


  end






end
