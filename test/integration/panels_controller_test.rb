require 'minitest/autorun'
require 'test_helper'
require 'mocha/test_unit'

require 'db_helper'
require 'controller_integration_test_helper'

class PanelsControllerTest < ActionDispatch::IntegrationTest
  include DBHelper
  include ControllerIntegrationTestHelper

  def setup
    super
    authenticate_session!

    @experiment = Scalarm::Database::Model::Experiment.new(user_id: @user.id)
    @experiment.save
  end

  def teardown
    super
  end

  test 'show with no standalone should return all analysis methods' do
    get panel_path(@experiment.id)

    assert_response :success

    panels = Panels.new(false)
    panels.groups.each do |_, group|
      group['methods'].each do |method|
        assert response.body.include?(method['name'])
      end
    end
  end

  test 'show with standalone should return standalone analysis methods only' do
    get panel_path(@experiment.id, stand_alone: true)

    assert_response :success

    panels = Panels.new(true)
    panels.groups.each do |_, group|
      group['methods'].each do |method|
        assert response.body.include?(method['name'])
      end
    end
  end
end