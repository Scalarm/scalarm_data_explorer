require 'scalarm/service_core/scalarm_authentication'

class ApplicationController < ActionController::Base
  include Scalarm::ServiceCore::ScalarmAuthentication

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  before_filter :authenticate
  rescue_from Scalarm::ServiceCore::AuthenticationError, with: :authentication_failed

  before_filter :add_cors_header

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

  def add_cors_header
    response['Access-Control-Allow-Origin'] = '*'
  end  
end
