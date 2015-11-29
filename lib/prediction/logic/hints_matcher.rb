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