class ScriptTagsController < ApplicationController
  def show
    @PREFIX = "/"
    if(params.has_key?(:base_url))
      @PREFIX = params[:base_url]
    end

    render html: "<script type=\"text/javascript\" src=\"#{@PREFIX}scripts/#{params[:id]}/\">"
# src=http://localhost/scripts/3d 
	end
	
end
