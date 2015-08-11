class ScriptTagsController < ApplicationController
  PREFIX = "/"
  def show
    #rendering hmtl script for experiment
    render html: ("<script type=\"text/javascript\" src=\"#{@prefix}/scripts/#{params[:id]}?base_url=#{params[:base_url]}\"/>").to_s.html_safe,
           layout: false
	end
	
end
