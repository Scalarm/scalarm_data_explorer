class PredictionsController < ApplicationController
  require (Rails.root.join('app','prediction',"logic","text_reader"))
  require (Rails.root.join('app','prediction',"logic","rule_processor"))
  require (Rails.root.join('app','prediction',"model","result_aggregator"))
  require (Rails.root.join('app','prediction',"model","consts","text_data"))
  require (Rails.root.join('app','prediction',"model","consts","labeled_data"))
  require (Rails.root.join('app','prediction',"model","consts","prediction"))
  require (Rails.root.join('app','prediction',"model","consts","number_of_samples"))

  def index

    render :index, layout: false
  end

  def show

    #data = params[:prediction_file]
    number_of_lines = params[:number_of_lines].to_i
    text_data = params[:text_data]
    to_predict = params[:to_predict]
    labeled_data = params[:labeled_data]

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

    rule_processor = RuleProcessor.new
    results = rule_processor.suggest(to_predict_sym,number_of_lines,text_data_sym,labeled_data_sym)
    Rails.logger.debug("results: #{results.hints}")
    Rails.logger.debug("results: #{results.algorithms}")
    Rails.logger.debug("results: #{results.notes}")
  end

  def evaluate
    Rails.logger.debug("Jetses w Evaluates!")
  end
end