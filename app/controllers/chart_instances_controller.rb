class ChartInstancesController < ApplicationController
  PREFIX = "/"
  def show
    experiment_id = params[:id].to_s
    @experiment = Scalarm::Database::Model::Experiment.find_by_id(experiment_id)

    @prefix = params[:base_url] || PREFIX
    @input_parameters = @experiment.get_parameter_ids
    #paramaters["moes"] = moes?
  # paramaters ?
   #user =  User.find(session[:user_id])

  	if @experiment.visible_to(params[:userID])
  	  render :file => Rails.root.join('app','visualisation_methods', params[:id], "#{params[:id]}_chart.html.haml")
  	else
  	  raise 'Not authorised'
  	end
  end
end
