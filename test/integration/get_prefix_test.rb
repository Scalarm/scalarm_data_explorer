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
    Rails.cache.clear
  end

  test 'base_url given in request parameters should be ignored' do
    prefix = 'bar'
    Utils.stubs(:random_service_public_url).with('data_explorers')
        .returns(nil)

    get '/foo', base_url: prefix, format: :json

    assert_response :success, body
    refute_equal prefix, body.to_s, body
  end

  test '@prefix controller variable should be set to value from configuration if given' do
    prefix = 'bar'

    Rails.application.secrets.stubs(:base_url).returns(prefix)

    get '/foo', format: :json

    assert_response :success, body
    assert_equal prefix, body.to_s, body
  end

  # Also "https://" will be as IS address prefix
  test '@prefix should be set to random value from IS if no base_url in configuration given' do
    ## Given
    addresses = ['one', 'two']
    urls = addresses.collect {|a| "https://#{a}"}
    information_service = mock 'information_service' do
      stubs(:get_list_of).with('data_explorers').returns(addresses)
    end
    # Override test base_url config
    Rails.application.secrets.stubs(:base_url).returns(nil)
    InformationService.stubs(:instance).returns(information_service)

    ## When
    get '/foo', format: :json

    ## Then
    assert_response :success, "Not success response: #{body}"
    assert_includes urls, body.to_s, body
  end

  test '@prefix controller variable should be set to PREFIX const if there is no other prefix candidates' do
    ## Given
    Utils.stubs(:random_service_public_url).with('data_explorers')
        .returns(nil)

    # Override test base_url config
    Rails.application.secrets.stubs(:base_url).returns(nil)

    ## When
    get '/foo', format: :json

    ## Then
    assert_response :success, body
    assert_equal ApplicationController::PREFIX, body.to_s, body
  end

end