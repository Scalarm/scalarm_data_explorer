require 'scalarm/service_core/utils'

module Utils
  # extend this Utils with Scalarm::ServiceCore::Utils module methods
  class << self
    Scalarm::ServiceCore::Utils.singleton_methods.each do |m|
      define_method m, Scalarm::ServiceCore::Utils.method(m).to_proc
    end
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