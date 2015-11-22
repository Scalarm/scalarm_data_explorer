class AlgorithmAttributes

  attr_reader :prediction, :samples, :textData, :labeledData

  def initialize(prediction, samples, textData, labeledData)
    @prediction = prediction
    @samples = samples
    @textData = textData
    @labeledData = labeledData
  end

end