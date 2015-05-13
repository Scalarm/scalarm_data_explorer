class MoesController < ApplicationController
    def show

      experiment_id = params[:id].to_s
      experiment = Scalarm::Database::Model::Experiment.find_by_id(experiment_id)

      filter = {is_done: true, is_error: {'$exists'=> false}}
			fields = {fields: {result: 1}}
			#user =  User.find_by_id(session[:user_id].to_s)
  	  #if @experiment.visible_to(user)

      begin
  	    result = experiment.simulation_runs.where(filter, fields).first.result
        render json: result
      rescue => e
        render json: {}, status: 404
      end
  	      #JSON.stringify(data.result));
  	  #else
  	   # raise 'Not authorised'
  	  #end
	end

end
