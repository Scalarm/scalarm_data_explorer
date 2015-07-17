require 'erb'
class ScriptsController < ApplicationController
  include ERB::Util
  def show
    #render experiment chart
    render file: Rails.root.join('app','visualisation_methods', ERB::Util.h(params[:id]), "chart.js"),
           layout: false,
           content_type: 'text/javascript'
  end
end
