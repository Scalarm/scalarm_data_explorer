class MoesController < ApplicationController
    def show

      experiment_id = params[:id].to_s
      @experiment = Scalarm::Database::Model::Experiment.find_by_id(experiment_id)
    
  	  if @experiment.visible_to(params[:userID])
  	    @parameters = @experiment.get_parameter_ids
  	    #JSON.stringify(data.result));
  	  else
  	    raise 'Not authorised'
  	  end
	end

end
