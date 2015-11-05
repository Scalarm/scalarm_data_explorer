require 'scalarm/service_core/utils'

module Utils
  # extend this Utils with Scalarm::ServiceCore::Utils module methods
  class << self
    Scalarm::ServiceCore::Utils.singleton_methods.each do |m|
      define_method m, Scalarm::ServiceCore::Utils.method(m).to_proc
    end
  end

  # TODO: A good candidate to generic function in Scalarm::ServiceCore
  # Returns random public address from IS with https:// prefix
  # If there is no adresses registered - returns nil
  # Arguments:
  # * service - plurar name of service - e.g. data_explorers
  def self.random_service_public_url(service)
    addresses = Rails.cache.fetch("#{service}_adresses", expires_in: 30.minutes) do
      InformationService.instance.get_list_of(service)
    end

    random_address = addresses.try(:sample)
    random_address.nil? ? nil : "https://#{random_address}"
  end

  def self.require_plugin(chart_id)
    path = Rails.root.join('app','visualisation_methods',"#{chart_id}","plugin")
    require(path)
  end

  def self.generate_content_with_plugin(chart_id, experiment, params)
    handler = chart_id.camelize.constantize.new
    handler.experiment = experiment
    handler.parameters = params
    handler.handler
  end

  ##
  # check which parameters and moes have no more than n values and return array of ids
  def self.param_ids_with_less_than_n_values(experiment, n)
    filter = {is_done: true, is_error: {'$exists'=> false}}
    simulation_runs = experiment.simulation_runs.where(filter).to_a
    allowed_params = []
    if simulation_runs != []
      params_ids = simulation_runs.first.arguments.split(",")
      out_params_ids = simulation_runs.first.result.keys
      parameters = {}
      params_ids.each do |param_id|
        parameters[param_id] = []
      end
      out_params_ids.each do |param_id|
        parameters[param_id] = []
      end
      simulation_runs.each do |simulation_run|
        values = simulation_run.values.split(',')
        params_ids.each_with_index do |param_id, index|
          parameters[param_id] |= [values[index]]
        end
        simulation_run.result.each do |key, value|
          parameters[key] |= [value]
        end
      end
      parameters.each do |key, value|
        if value.length <= n
          allowed_params.push(key)
        end
      end
    end
    allowed_params
  end

end