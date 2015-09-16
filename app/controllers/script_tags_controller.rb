require 'erb'
class ScriptTagsController < ApplicationController
  include ERB::Util

  def show
    analysisMethodsConfig = AnalysisMethodsConfig.new
    methods = analysisMethodsConfig.get_method_names
    #validating chart_id (name of method)
    validate(
        id: Proc.new do |param_name, value|
          unless methods.include? value
            raise "Wrong chart name"
          end
        end
    )
    #rendering hmtl script for experiment
    render html: ("<script type=\"text/javascript\" src=\"#{@prefix}/scripts/#{ERB::Util.h(params[:id])}?base_url=#{@prefix}\"/>").to_s.html_safe,
           layout: false
	end
	
end
