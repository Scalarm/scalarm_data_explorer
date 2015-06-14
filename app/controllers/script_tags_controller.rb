class ScriptTagsController < ApplicationController
  PREFIX = "/"
  def show
    #rendering hmtl script for experiment
    render html: "<script type=\"text/javascript\" src=\"#{@prefix}/scripts/#{params[:id]}\"/>"

	end
	
end
