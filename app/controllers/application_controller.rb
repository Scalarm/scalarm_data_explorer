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
  rescue_from SecurityError, with: :security_exception_handler
  rescue_from MissingParametersError, with: :security_exception_handler

  PREFIX = '/'
  attr_reader :prefix
  # make prefix accessible in helpers to use full path
  helper_method :prefix
  before_filter :load_prefix

  before_filter :check_request_origin
  before_filter :cors_preflight_check
  after_filter :add_cors_header

  before_filter :validate_common_params

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
    if experiment_id.blank?
      raise MissingParametersError, ['id']
    end

    @experiment = Scalarm::Database::Model::Experiment.visible_to(current_user).find_by_id(experiment_id)
    unless @experiment
      raise SecurityError, "Cannot get data for experiment with ID: #{experiment_id}"
    end
  end

  ##
  # Evaluate prefix (base_url) in order:
  # 1. base_url key from local configuration (currently secrets)
  # 2. from Information Service (cached) with https:// appended
  # 3. or use PREFIX const
  def find_prefix
    url_from_config = Rails.application.secrets.base_url
    url_from_config || Utils.random_service_public_url('data_explorers') || PREFIX
  end

  ##
  # Set @prefix (html escaped)
  def load_prefix
    @prefix = ERB::Util.h(find_prefix)
  end

  def security_exception_handler(exception)
    Rails.logger.debug(exception)
    Rails.logger.warn("Exception caught in security_exception_handler: #{exception.message}")
    Rails.logger.debug("Exception backtrace:\n#{exception.backtrace}")
    add_cors_header
    respond_to do |format|
      format.html do
        render html: exception.to_s, status: 412
      end

      format.json do
        render json: {
                   status: 'error',
                   reason: exception.to_s
               },
               status: 412
      end
    end
  end

  def generic_exception_handler(exception)
    Rails.logger.warn("Exception caught in generic_exception_handler: #{exception.message}")
    Rails.logger.debug("Exception backtrace:\n#{exception.backtrace}")
    Rails.logger.debug(exception)
    add_cors_header
    respond_to do |format|
      format.html do
        #flash[:error] = exception.to_s
        render html: exception.to_s, status: 500
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

  # Some request params are common for multiple (or all) controllers.
  # Validate them here, if they exists in query.
  def validate_common_params
    validate(
        stand_alone: [:optional, :_validate_boolean]
    )
  end

  # TODO: move this validator to common libraries
  # Check if value of param named name is stringified boolean, boolean or nil
  # If not, raise ValidationError
  def _validate_boolean(name, value)
    unless [nil, 'true', 'false', true, false].include?(value)
      raise ValidationError.new(name, value, 'Only valid values are "true" or "false"')
    end
  end

  def standalone
    params.include?(:stand_alone) and (params[:stand_alone] == 'true')
  end

  protected :authentication_failed, :standalone

end
