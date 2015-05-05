class ScriptController < ApplicationController
  def show
		# params[:id]
		render html: "<script type=\"text/javascript\" src=\"/scripts/#{params[:id]}/\">"
# src=http://localhost/scripts/3d 
	end
end
