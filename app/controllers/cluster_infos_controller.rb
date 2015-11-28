class ClusterInfosController < ApplicationController
  before_filter :load_experiment, only: :show
  include Scalarm::ServiceCore::ParameterValidation

=begin
apiDoc:
  @api {get} /cluster_infos/:id Cluster statistical description
  @apiName cluster_infos#show
  @apiGroup ClusterInfos
  @apiDescription Returns html or json with statistical information about simulation runs for input and output parameters.
  When called, it validates 'simulations' parameter and then creates list of integer values from this variable.
  Next, it initializes ClusterInfos class and invokes 'evaluate' class method which firstly creates result set and then calculates statistical factors.
  Json contain 2 fields status (ok / error) and data (hash) with calculated mean, variance, skewness, kurtosis, median, standard_deviation, upper/lower quartiles, argument ranges for all experiment parameters.

  @apiParam {String} id ID of experiment
  @apiParam {String} simulations ids of simulation runs separated with comma
  @apiParam {String} cluster_id ID (name) of cluster
  @apiParam {String} chart_name name of method

  @apiSuccessExample {json} Success-Response with 4 parameters: 2 input -> parameter1, parameter2 and 2 output -> product, product_2
  {
    "status":"ok",
    "data":{
      "skewness":{
        "parameter1":"-0.04886349676586589",
        "parameter2":"-0.00829557446875768",
        "product":"0.21478515328136372",
        "product_2":"0.21478515328136372"
      },
      "kurtosis":{
        "parameter1":"-1.2428034469885048",
        "parameter2":"-1.186212469310383",
        "product":"0.3315460920718629",
        "product_2":"0.3315460920718629"
      },
      "means":{
        "parameter1":"508.3783783783784",
        "parameter2":"1.7635135135135136",
        "product":"2429.2905405405404",
        "product_2":"2430.2905405405404"
      },
      "medians":{
        "parameter1":"495.0",
        "parameter2":"-5.0",
        "product":"0.0",
        "product_2":"1.0"
      },
      "variances":{
        "parameter1":"105777.77574872156",
        "parameter2":"12902.167047114686",
        "product":"4508059653.043964",
        "product_2":"4508059653.043964"
      },
      "standard_deviation":{
        "parameter1":"325.2349546846427",
        "parameter2":"113.58770640837277",
        "product":"67142.08555774808",
        "product_2":"67142.08555774808"
      },
      "lower_quartiles":{
        "parameter1":"165.0",
        "parameter2":"-83.0",
        "product":"-34980.0",
        "product_2":"-34979.0"
      },
      "upper_quartiles":{
        "parameter1":"825.0",
        "parameter2":"112.0",
        "product":"34278.75",
        "product_2":"34279.75"
      },
      "inter_quartile_ranges":{
        "parameter1":"660.0",
        "parameter2":"195.0",
        "product":"69258.75",
        "product_2":"69258.75"
      },
      "arguments_ranges":{
        "parameter1":"[0.0, 990.0, 990.0]",
        "parameter2":"[-200.0, 190.0, 390.0]",
        "product":"[-185130.0, 188100.0, 373230.0]",
        "product_2":"[-185129.0, 188101.0, 373230.0]"
      }
    }
  }
=end

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