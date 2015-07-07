class MoesController < ApplicationController
  before_filter :load_experiment, only: :show

  def show
    experiment_id = params[:id].to_s

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
