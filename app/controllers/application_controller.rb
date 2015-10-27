require 'scalarm/service_core/scalarm_authentication'
require 'scalarm/service_core/cors_support'
require 'erb'
class ApplicationController < ActionController::Base
  include Scalarm::ServiceCore::ScalarmAuthentication
  include Scalarm::ServiceCore::CorsSupport
  include Scalarm::ServiceCore::ParameterValidation
  include ERB::Util

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  #protect_from_forgery with: :null_session

  before_filter :authenticate, except: :status
  rescue_from Scalarm::ServiceCore::AuthenticationError, with: :authentication_failed
  rescue_from StandardError, with: :generic_exception_handler
  rescue_from SecurityError, with: :generic_exception_handler
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

  ##
  # Loads experiment by resource id (params[:experiment_id] or params[:id])
  # with view permission checking
  # if successful, experiment will be loaded to @experiment
  # otherwise, exception will be raised
  # TODO: create special error classes to raise
  def load_experiment
    validate(
      experiment_id: [:security_default, :optional],
      id: [:security_default, :optional]
    )
    experiment_id = (params[:experiment_id] || params[:id])
    raise 'No experiment ID specified, cannot load experiment' unless experiment_id
    @experiment = Scalarm::Database::Model::Experiment.visible_to(current_user).find_by_id(experiment_id)
    raise "Cannot get data for experiment with ID: #{experiment_id}" unless @experiment
  end

  ##
  # Base url adding escaping html
  def get_prefix
    text =(params[:base_url].to_s) || PREFIX
    @prefix = ERB::Util.h(text)
  end


  def generic_exception_handler(exception)
    Rails.logger.warn("Exception caught in generic_exception_handler: #{exception.message}")
    Rails.logger.debug("Exception backtrace:\n#{exception.backtrace.join("\n")}")
    add_cors_header
    respond_to do |format|
      format.html do
        #flash[:error] = exception.to_s
        render html: "An error occurred: #{exception.to_s}", status: 500
      end

      format.json do
        render json: {
                   status: 'error',
                   reason: exception.to_s
               },
               status: 500
      end
    end
  end

  protected :authentication_failed
end
