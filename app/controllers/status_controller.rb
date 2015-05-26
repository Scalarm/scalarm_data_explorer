require 'scalarm/service_core/utils'

class StatusController < ApplicationController

  ##
  # Simple welcome response
  def welcome
    respond_to do |format|
      format.html { render html: 'Welcome to SclarmChartService', status: :success }
      format.json { render json: {status: 'ok', message: 'Welcome to ScalarmChartService' } }
    end
  end

  def status
    tests = Scalarm::ServiceCore::Utils.parse_json_if_string(params[:tests])

    status = 'ok'
    message = ''

    unless tests.nil?
      failed_tests = tests.select { |t_name| not send("status_test_#{t_name}") }

      unless failed_tests.empty?
        status = 'failed'
        message = "Failed tests: #{failed_tests.join(', ')}"
      end
    end

    http_status = (status == 'ok' ? :ok : :internal_server_error)

    respond_to do |format|
      format.html do
        render text: message, status: http_status
      end
      format.json do
        render json: {status: status, message: message}, status: http_status
      end
    end
  end

  # --- Status tests ---

  def status_test_database
    Scalarm::Database::MongoActiveRecord.available?
  end
end
