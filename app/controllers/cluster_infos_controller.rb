require 'benchmark'
class ClusterInfosController < ApplicationController
  before_filter :load_experiment, only: :show

  #Id -> experimentId; simulations => 2,4,6,1,6
  def show
    simulations = params[:simulations].split(',').map{|s| s.to_i}
    if simulations.include? 0
      raise "Error: simulation not exists"
    end
    clusterInfos = ClusterInfos.new(@experiment,simulations)
    @content = clusterInfos.evaluate
    respond_to do |format|
      #change it for display
      format.html { render :html => content}
      format.json { render json: {status: 'ok', data: content } }

    end

  end

end