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
    # super
  end

  test "should get show" do
    # require 'scalarm/database'
    #
    # experiment = Scalarm::Database::Model::Experiment.new(a: 1)
    # experiment.save
    # @experiment = Scalarm::Database::Model::Experiment.find_by_id(experiment.id)
    # get :show, id: experiment.id
    #
    # puts response.body
    # assert_response :success


    stub_authentication
    experiment1_id = BSON::ObjectId.new
    PanelsController.any_instance.stubs(:handle_panel_for_experiment)
    panels = Panels.new('false')

    analysisMethodsConfig = AnalysisMethodsConfig.new
    analysisMethodsConfig.stubs(:get_groups).returns([{"basic"=>{"name"=>"Variate analysis", "methods"=>[{"name"=>"Histogram", "id"=>"experiment-analysis-modal", "em_class"=>"histogram-analysis", "image"=>"histogram_icon.png", "description"=>"A histogram analysis shows results frequency distributions"}, {"name"=>"Scatter plot", "id"=>"experiment-analysis-modal", "em_class"=>"bivariate-analysis", "image"=>"scatter_icon.png", "description"=>"Analysis of two variables relationship creates a scatter plot"}, {"name"=>"Linear", "id"=>"lindev", "group"=>"basic", "image"=>"lindev_icon.png", "description"=>"Line chart with standard deviation"}, {"name"=>"3D chart", "id"=>"three_d", "group"=>"basic", "image"=>"3dchart_icon.png", "description"=>"3D charts - scatter plot"}]}, "params"=>{"name"=>"Parameters influence", "methods"=>[{"name"=>"Regression trees", "id"=>"experiment-analysis-modal", "em_class"=>"rtree-analysis", "image"=>"regression_icon.png", "description"=>"The classification of objects by dividing the found set of conditions"}, {"name"=>"Pareto", "id"=>"pareto", "group"=>"params", "image"=>"pareto_icon.png", "description"=>"Chart showing significance of parameters (or interaction)"}, {"name"=>"Interaction", "id"=>"interaction", "group"=>"params", "image"=>"interaction_icon.png", "description"=>"Shows interaction between 2 input parameters"}, {"name"=>"Hierarchical clustering", "id"=>"dendrogram", "group"=>"params", "image"=>"dendrogram_icon.png", "description"=>"Method of cluster analysis which builds a hierarchy of clusters and shows it on dendrogram"}, {"name"=>"K-means clustering", "id"=>"kmeans", "group"=>"params", "image"=>"k_means_icon.png", "description"=>"Clustering charts - k-means clustering"}]}}])

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
    puts @groups

    get :index, id: experiment.id
    puts experiment.id
    # assert_response :success
  end
end
