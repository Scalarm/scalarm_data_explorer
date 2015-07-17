require 'erb'
class ScriptsController < ApplicationController
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
    #render experiment chart
    render file: Rails.root.join('app','visualisation_methods', ERB::Util.h(params[:id]), "chart.js"),
           layout: false,
           content_type: 'text/javascript'
  end
end
