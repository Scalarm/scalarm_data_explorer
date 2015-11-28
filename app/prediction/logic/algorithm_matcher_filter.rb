require_relative '../model/algorithm_matchers'


class AlgorithmMatcherFilter

  attr_reader :algorithm_matchers

  def initialize(algorithm_matchers)
    @algorithm_matchers = algorithm_matchers
  end

  def filter_by_prediction(prediction)
    @algorithm_matchers.delete_if { |element|
      not (element.algorithmAttributes.prediction == prediction || element.algorithmAttributes.prediction == Prediction.anything)
    }
    @algorithm_matchers
  end

  def filter_by_number_of_samples(samples)
    if samples <= 50 then
      @algorithm_matchers.delete_if { |element|
        not (element.algorithmAttributes.samples == NumberOfSamples.less_than_50)
      }
    elsif samples > 100_000 then
      @algorithm_matchers.delete_if { |element|
        not (element.algorithmAttributes.samples == NumberOfSamples.moreThan10k || element.algorithmAttributes.samples == NumberOfSamples.more_than_100k)
      }
    elsif samples > 10_000 then
      @algorithm_matchers.delete_if { |element|
        not (element.algorithmAttributes.samples == NumberOfSamples.moreThan10k || element.algorithmAttributes.samples == NumberOfSamples.more_than_50_less_than_100k)
      }
    else
      @algorithm_matchers.delete_if { |element|
        not (element.algorithmAttributes.samples == NumberOfSamples.more_than_50_less_than_10k || element.algorithmAttributes.samples == NumberOfSamples.more_than_50_less_than_100k)
      }
    end
    @algorithm_matchers
  end

  def filter_by_text_data(text_data)
    @algorithm_matchers.delete_if { |element|
      not (element.algorithmAttributes.text_data == text_data || element.algorithmAttributes.text_data == TextData.not_relevant)
    }
    @algorithm_matchers
  end

  def filter_by_labeled_data(labeled_data)
    @algorithm_matchers.delete_if { |element|
      not (element.algorithmAttributes.labeled_data == labeled_data || element.algorithmAttributes.labeled_data == LabeledData.no_info)
    }
    @algorithm_matchers
  end

  def filter(prediction, samples, text_data, labeled_data)
    filter_by_prediction(prediction)
    filter_by_number_of_samples(samples)
    filter_by_text_data(text_data)
    filter_by_labeled_data(labeled_data)
    @algorithm_matchers
  end

end