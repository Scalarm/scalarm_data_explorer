class ModalsController < ApplicationController
  before_filter :load_experiment, only: :show

=begin
apiDoc:
  @api {get} /modals/:id Modal window rendering
  @apiName modals#show
  @apiGroup Modals
  @apiDescription Returns html with prepared modal window for particular chart.
  When called, validates chart name (:id).
  Then uses visualisation method plugin (located at /app/visualisation_methods in application) to render modal with HTML and JavaScript (draw function) content intended for particular experiment (:experiment_id).
  Modal content also contains JS functions which handle button clicks e.g. load chart or refresh.

  @apiParam {String} id chart method name
  @apiParam {String} experiment_id ID of experiment
=end

  def show
    # get config
    analysis_methods_config = AnalysisMethodsConfig.new
    methods = analysis_methods_config.get_method_names
    # TODO: using _validate_boolean which is defined in ApplicationController - maybe it will be moved to libs
    validate(
        # validating chart_id (name of method)
        id: Proc.new do |param_name, value|
          unless methods.include? value
            raise SecurityError.new("Wrong chart name")
          end
        end,
        moes_info_exist: [:optional, :_validate_boolean]
    )
    #get method name
    chart_id = params[:id].to_s

    # get modal file to string
    modal_content = render_to_string :file => Rails.root.join('app','visualisation_methods', chart_id, "_modal.html.haml"), layout: standalone
    # get draw function body to string
    chart_file_content = render_to_string :file => Rails.root.join('app','visualisation_methods', chart_id,"chart.js"), layout: false
    #render both to site
    render :html => modal_content + '<script>'.to_s.html_safe + chart_file_content + '</script>'.to_s.html_safe
  end
end
