require 'scalarm/service_core/scalarm_authentication'
require 'scalarm/service_core/cors_support'

class ApplicationController < ActionController::Base
  include Scalarm::ServiceCore::ScalarmAuthentication
  include Scalarm::ServiceCore::CorsSupport

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  before_filter :authenticate, except: :status
  rescue_from Scalarm::ServiceCore::AuthenticationError, with: :authentication_failed

  PREFIX = '/'
  before_filter :get_prefix

  before_filter :check_request_origin
  before_filter :cors_preflight_check
  after_filter :add_cors_header

  def authentication_failed
    Rails.logger.debug('[authentication] failed -> 401')
    @user_session.destroy unless @user_session.nil?

    respond_to do |format|
      format.html do
        render html: 'Authentication failed', status: :unauthorized
      end
      format.json do
        render json: {status: 'error', reason: 'Authentication failed'}, status: :unauthorized
      end
    end
  end

  def get_prefix
    @prefix = (params[:base_url].to_s) || PREFIX
  end

  protected :authentication_failed
end