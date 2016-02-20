class ClusterInfosController < ApplicationController
  before_filter :load_experiment, only: :show
  include Scalarm::ServiceCore::ParameterValidation
  #Id -> experimentId; simulations => 2,4,6,1,7
  def show
    validate(
        chart_id: :security_default
    )

    begin
      simulations = params[:simulations].split(',').map { |s| s.to_i }
    rescue => e
      raise MissingParametersError.new(["simulations"])
    end

    if simulations.include? 0
      raise SecurityError.new("Simulation not exists")
    end
    cluster_infos = ClusterInfos.new(@experiment, simulations)
    @content = cluster_infos.evaluate

    @content.update(@content) { |k, v| v.kind_of?(Array) ?
        v.map! { |array_value| ERB::Util.h(array_value) } : v.kind_of?(Hash) ?
            v.update(v) { |k_s, v_s| ERB::Util.h(v_s) } : ERB::Util.h(v) }

    if params[:stand_alone] == 'false' || params[:stand_alone].nil?
      layout_value = false
    else
      layout_value = true
    end

    respond_to do |format|
      format.html { render layout: layout_value }
      format.json { render json: {status: 'ok', data: @content } }

    end
  end
end