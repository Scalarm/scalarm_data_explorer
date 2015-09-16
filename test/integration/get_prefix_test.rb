require 'csv'
require 'minitest/autorun'
require 'mocha/test_unit'

require 'active_support'

require 'scalarm/service_core'
require 'scalarm/service_core/logger'
require 'scalarm/service_core/test_utils/authentication_test_cases'


class PrefixTestsController < ApplicationController
  def foo
    render plain: @prefix.to_s
  end
end

##
# Tests if get_prefix from ApplicationController sets @prefix properly
class GetPrefixTest < ActionDispatch::IntegrationTest
  Scalarm::ServiceCore::Logger.set_logger(Rails.logger)

  def setup
    super
    stub_authentication

    Rails.application.routes.draw do
      get 'foo' => 'prefix_tests#foo'
    end
  end

  def teardown
    super
    Rails.application.reload_routes!
  end

  test '@prefix controller variable should be set to value given as base_url parameter' do
    prefix = 'bar'

    get '/foo', base_url: prefix, format: :json

    assert_response :success
    assert_equal prefix, body.to_s, body
  end

  test '@prefix controller variable should be set to PREFIX const if base_url parameter not given' do
    get '/foo', format: :json

    assert_response :success
    assert_equal ApplicationController::PREFIX, body.to_s, body
  end

end