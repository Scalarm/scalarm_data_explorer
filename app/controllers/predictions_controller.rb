class PredictionsController < ApplicationController

  require (Rails.root.join('app','prediction',"logic","rule_processor"))
  require (Rails.root.join('app','prediction',"model","result_aggregator"))
  require (Rails.root.join('app','prediction',"model","consts","text_data"))
  require (Rails.root.join('app','prediction',"model","consts","labeled_data"))
  require (Rails.root.join('app','prediction',"model","consts","prediction"))

  before_filter :load_experiment

  def index
    render :index, layout: false
  end

  def show


=begin
    query_fields = {_id: 0}
    query_fields[:values] = 1
    query_fields[:result] = 1
    sim_check = simulations.where(
        {is_done: true},
        {fields: query_fields}
    ).first

    input_params = sim_check["values"].split(',')
    input_params.each do |parameter|
      unless parameter.match(/ ^[-+]?[0-9]*\.?[0-9]+$/)
        text_data_sym = TextData.yes
      end
    end
    sim_check["result"].each do |moes|
      if moes.kind_of?(String)l
        text_data_sym = TextData.yes
    end

=end

    text_data = params[:text_data]
    to_predict = params[:to_predict]
    labeled_data = params[:labeled_data]

    simulations = @experiment.simulation_runs
    number_of_lines =  simulations.count

    text_data_sym=TextData.notRelevant
    case text_data
      when "yes"
        text_data_sym = TextData.yes
      when "no"
        text_data_sym = TextData.no
      else
        text_data_sym = TextData.notRelevant
    end


    to_predict_sym = Prediction.noInfo
    case to_predict
      when "category - with known number of categories"
        to_predict_sym = Prediction.categoryWithKnownNumberOfCategories
      when "quantity"
        to_predict_sym = Prediction.quantity
      when "structure"
        to_predict_sym = Prediction.structure
      when "category - with unknown number of categories"
        to_predict_sym = Prediction.categoryWithUnknownNumberOfCategories
      else
        to_predict_sym = Prediction.noInfo
    end

    labeled_data_sym = LabeledData.noInfo
    case labeled_data
      when "yes"
        labeled_data_sym = LabeledData.yes
      when "no"
        labeled_data_sym = LabeledData.no
      else
        labeled_data_sym = LabeledData.noInfo
    end

    results = RuleProcessor.new.suggest(to_predict_sym,number_of_lines,text_data_sym,labeled_data_sym)
    algorithms = []
    results.algorithms.each do |algorithm_matcher|
      algorithm_spec = algorithm_matcher.algorithm.name.to_s + " - " + algorithm_matcher.algorithm.description.to_s
      algorithms.push(algorithm_spec)
    end
    @prediction_results = { hints: results.hints, algorithms: algorithms, notes: results.notes }
    render :show, layout: false
  end

  def evaluate
  end
end