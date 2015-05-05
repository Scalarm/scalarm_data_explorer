require 'test_helper'

class ScriptControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

end
