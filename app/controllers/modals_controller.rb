class ModalsController < ApplicationController
  before_filter :load_experiment, only: :show

  ##
  # id -> modal ID
  def show
    # get config
    analysisMethodsConfig = AnalysisMethodsConfig.new
    methods = analysisMethodsConfig.get_method_names
    # validating chart_id (name of method)
    validate(
        id: Proc.new do |param_name, value|
          unless methods.include? value
            raise SecurityError.new("Wrong chart name")
          end
        end
    )
    #get method name
    chart_id = params[:id].to_s

    # get modal file to string
    modal_content = render_to_string :file => Rails.root.join('app', 'visualisation_methods', chart_id, "_modal.html.haml"), layout: false
    # get draw function body to string
    chart_file_content = render_to_string :file => Rails.root.join('app', 'visualisation_methods', chart_id, "chart.js"), layout: false
    #render both to site
    render :html => modal_content + '<script>'.to_s.html_safe + chart_file_content + '</script>'.to_s.html_safe
  end


end
