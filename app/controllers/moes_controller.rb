require 'erb'
class MoesController < ApplicationController
  before_filter :load_experiment, only: :show
  include ERB::Util
  def show

    filter = {is_done: true, is_error: {'$exists'=> false}}
    fields = {fields: {result: 1}}
    begin
      result = @experiment.simulation_runs.where(filter, fields).first.result
      render json: result
    rescue => e
      Rails.logger.error "Getting moes ids failed: #{e}"
      render json: {}, status: 500
    end
	end

end
