class AlgorithmAttributes

  attr_reader :prediction, :samples, :text_data, :labeled_data

  def initialize(prediction, samples, text_data, labeled_data)
    @prediction = prediction
    @samples = samples
    @text_data = text_data
    @labeled_data = labeled_data
  end

end