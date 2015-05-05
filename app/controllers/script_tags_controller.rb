class ScriptTagsController < ApplicationController
  
  
	def show
	  render file: Rails.root.join('app','visualisation_methods', params[:id], "#{params[:id]}_chart.js") or raise not_found
	end
end
