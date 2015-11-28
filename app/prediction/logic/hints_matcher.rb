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
    @text_data = textData
    @labeled_data = labeledData
  end

  def gatherHints
    @hints = PredictionHints.get_hints(@prediction) +
              LabeledDataHints.get_hints(@labeled_data) +
              TextDataHints.get_hints(@text_data) +
              NumberOfSamplesHints.get_hints(@samples)
  end

end