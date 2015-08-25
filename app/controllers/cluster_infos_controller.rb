class ClusterInfosController < ApplicationController
  before_filter :load_experiment, only: :show

  #Id -> experimentId; simulations => 2,4,6,1,7
  def show
    simulations = params[:simulations].split(',').map{|s| s.to_i}
    if simulations.include? 0
      raise "Error: simulation not exists"
    end
    cluster_infos = ClusterInfos.new(@experiment,simulations)
    @content = cluster_infos.evaluate

    respond_to do |format|
      format.html { render layout: false }
      format.json { render json: {status: 'ok', data: @content } }
    end
  end
end