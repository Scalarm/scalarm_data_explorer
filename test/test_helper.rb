ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'scalarm/service_core/test_utils/test_helper_extensions'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  # ative rerord disabled
  # fixtures :all

  # Add more helper methods to be used by all tests here...

  include Scalarm::ServiceCore::TestUtils::TestHelperExtensions
end
