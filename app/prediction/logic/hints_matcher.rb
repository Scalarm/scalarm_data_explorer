require_relative '../model/consts/prediction'
require_relative '../model/consts/number_of_samples'
require_relative '../model/consts/text_data'
require_relative '../model/consts/labeled_data'
require_relative '../model/hints/prediction_hints'
require_relative '../model/hints/text_data_hints'
require_relative '../model/hints/number_of_samples_hints'
require_relative '../model/hints/labeled_data_hints'


class HintsMatcher

  def initialize(prediction, samples, textData, labeledData)
    @prediction = prediction
    @samples = samples
    @textData = textData
    @labeledData = labeledData
  end

  def gatherHints
    Rails.logger.debug()
    @hints = PredictionHints.getHints(@prediction) +
              LabeledDataHints.getHints(@labeledData) +
              TextDataHints.getHints(@textData) +
              NumberOfSamplesHints.getHints(@samples)
  end

end

