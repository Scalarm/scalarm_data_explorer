class MoesController < ApplicationController
    def show

      experiment_id = params[:id].to_s
      @experiment = Scalarm::Database::Model::Experiment.find_by_id(experiment_id)
      filter = {is_done: true, is_error: {'$exists': false}};
	  fields = {fields: {result: 1}};
  	  #if @experiment.visible_to(params[:userID])
  	  @parameters = @experiment.simulation_runs.find(filter,fields)
  	    #JSON.stringify(data.result));
  	  #else
  	   # raise 'Not authorised'
  	  #end
	end

end
