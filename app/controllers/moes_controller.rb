require 'erb'
class MoesController < ApplicationController
  before_filter :load_experiment, only: :show
  include ERB::Util

=begin
apiDoc:
  @api {get} /moes/:id Moes description
  @apiName moes#show
  @apiGroup Moes
  @apiDescription Returns json with experiment moes


  @apiParam {String} id ID of experiment
  @apiSuccess {json} render json with experiment moes result

=end

  def show

    filter = {is_done: true, is_error: {'$exists' => false}}
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
