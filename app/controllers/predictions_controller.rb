class PredictionsController < ApplicationController

  before_filter :load_experiment

=begin
apiDoc:
  @api {get} /predictions prediction modal view
  @apiName predictions#index
  @apiGroup Predictions
  @apiDescription Returns modal view for chart predictions

=end

  def index
    render :index, layout: false
  end


=begin
apiDoc:
  @api {get} /predictions/:id  prediction main view
  @apiName predictions#show
  @apiGroup Predictions

  @apiParam {String} id ID of experiment
  @apiParam {String} text_data Are string-type parameters in input?
  @apiParam {String} to_predict what to predict
  @apiParam {String} labeled_data data have labels?

  @apiDescription Returns chart predictions hints as rendered html modal

=end
  def show

    text_data = params[:text_data]
    to_predict = params[:to_predict]
    labeled_data = params[:labeled_data]

    simulations = @experiment.simulation_runs
    number_of_lines = simulations.count

    text_data_sym=TextData.not_relevant
    case text_data
      when "yes"
        text_data_sym = TextData.yes
      when "no"
        text_data_sym = TextData.no
      else
        text_data_sym = TextData.not_relevant
    end


    to_predict_sym = Prediction.anything
    case to_predict
      when "category - with known number of categories"
        to_predict_sym = Prediction.category_known_number_of_categories
      when "quantity"
        to_predict_sym = Prediction.quantity
      when "structure"
        to_predict_sym = Prediction.structure
      when "category - with unknown number of categories"
        to_predict_sym = Prediction.category_unknown_number_of_categories
      else
        to_predict_sym = Prediction.anything
    end

    labeled_data_sym = LabeledData.no_info
    case labeled_data
      when "yes"
        labeled_data_sym = LabeledData.yes
      when "no"
        labeled_data_sym = LabeledData.no
      else
        labeled_data_sym = LabeledData.no_info
    end

    results = RuleProcessor.new.suggest(to_predict_sym, number_of_lines, text_data_sym, labeled_data_sym)
    algorithms = []
    results.algorithms.each do |algorithm_matcher|
      algorithm_spec = algorithm_matcher.algorithm.name.to_s + " - " + algorithm_matcher.algorithm.description.to_s
      algorithms.push(algorithm_spec)
    end
    @prediction_results = {recommended_algorithms: algorithms, hints: results.hints, notes: results.notes}
    render :show, layout: false
  end

end