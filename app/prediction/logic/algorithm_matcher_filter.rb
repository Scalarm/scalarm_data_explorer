require_relative '../model/algorithm_matchers'


class AlgorithmMatcherFilter

  attr_reader :algorithmMatchers

  def initialize(algorithmMatchers)
    @algorithmMatchers = algorithmMatchers
  end

  def filterByPrediction(prediction)
    @algorithmMatchers.delete_if { |element|
      not (element.algorithmAttributes.prediction == prediction || element.algorithmAttributes.prediction == Prediction.noInfo)
    }
    @algorithmMatchers
  end

  def filterByNumberOfSamples(samples)
    if samples <= 50 then
      @algorithmMatchers.delete_if { |element|
        not (element.algorithmAttributes.samples == NumberOfSamples.lessThan50)
      }
    elsif samples > 100_000 then
      @algorithmMatchers.delete_if { |element|
        not (element.algorithmAttributes.samples == NumberOfSamples.moreThan10k || element.algorithmAttributes.samples == NumberOfSamples.moreThan100k)
      }
    elsif samples > 10_000 then
      @algorithmMatchers.delete_if { |element|
        not (element.algorithmAttributes.samples == NumberOfSamples.moreThan10k || element.algorithmAttributes.samples == NumberOfSamples.moreThan50LessThan100k)
      }
    else
      @algorithmMatchers.delete_if { |element|
        not (element.algorithmAttributes.samples == NumberOfSamples.moreThan50LessThan10k || element.algorithmAttributes.samples == NumberOfSamples.moreThan50LessThan100k)
      }
    end
    @algorithmMatchers
  end

  def filterByTextData(textData)
    @algorithmMatchers.delete_if { |element|
      not (element.algorithmAttributes.textData == textData || element.algorithmAttributes.textData == TextData.notRelevant)
    }
    @algorithmMatchers
  end

  def filterByLabeledData(labeledData)
    @algorithmMatchers.delete_if { |element|
      not (element.algorithmAttributes.labeledData == labeledData || element.algorithmAttributes.labeledData == LabeledData.noInfo)
    }
    @algorithmMatchers
  end

  def filter(prediction, samples, textData, labeledData)
    filterByPrediction(prediction)
    filterByNumberOfSamples(samples)
    filterByTextData(textData)
    filterByLabeledData(labeledData)
    @algorithmMatchers
  end

end


########################################################################################################################
algorithmMatcherFilter = AlgorithmMatcherFilter.new(AlgorithmMatchers.getAlgorithmsMatchers)
algorithmMatcherFilter.filterByPrediction(Prediction.categoryWithKnownNumberOfCategories)
raise "Wrong answer after filtering by prediction [categoryWithKnownNumberOfCategories]" unless algorithmMatcherFilter.algorithmMatchers.size == 7

algorithmMatcherFilter = AlgorithmMatcherFilter.new(AlgorithmMatchers.getAlgorithmsMatchers)
algorithmMatcherFilter.filterByPrediction(Prediction.categoryWithUnknownNumberOfCategories)
raise "Wrong answer after filtering by prediction [categoryWithUnknownNumberOfCategories]" unless algorithmMatcherFilter.algorithmMatchers.size == 12

algorithmMatcherFilter = AlgorithmMatcherFilter.new(AlgorithmMatchers.getAlgorithmsMatchers)
algorithmMatcherFilter.filterByPrediction(Prediction.quantity)
raise "Wrong answer after filtering by prediction [quantity]" unless algorithmMatcherFilter.algorithmMatchers.size == 8

algorithmMatcherFilter = AlgorithmMatcherFilter.new(AlgorithmMatchers.getAlgorithmsMatchers)
algorithmMatcherFilter.filterByPrediction(Prediction.structure)
raise "Wrong answer after filtering by prediction [structure]" unless algorithmMatcherFilter.algorithmMatchers.size == 5

algorithmMatcherFilter = AlgorithmMatcherFilter.new(AlgorithmMatchers.getAlgorithmsMatchers)
algorithmMatcherFilter.filterByPrediction(Prediction.noInfo)
raise "Wrong answer after filtering by prediction [noInfo]" unless algorithmMatcherFilter.algorithmMatchers.size == 4

########################################################################################################################
algorithmMatcherFilter = AlgorithmMatcherFilter.new(AlgorithmMatchers.getAlgorithmsMatchers)
algorithmMatcherFilter.filterByNumberOfSamples(20)
raise "Wrong answer after filtering by number of samples [20]" unless algorithmMatcherFilter.algorithmMatchers.size == 0

algorithmMatcherFilter = AlgorithmMatcherFilter.new(AlgorithmMatchers.getAlgorithmsMatchers)
algorithmMatcherFilter.filterByNumberOfSamples(50)
raise "Wrong answer after filtering by number of samples [50]" unless algorithmMatcherFilter.algorithmMatchers.size == 0

algorithmMatcherFilter = AlgorithmMatcherFilter.new(AlgorithmMatchers.getAlgorithmsMatchers)
algorithmMatcherFilter.filterByNumberOfSamples(1_000)
raise "Wrong answer after filtering by number of samples [1_000]" unless algorithmMatcherFilter.algorithmMatchers.size == 8

algorithmMatcherFilter = AlgorithmMatcherFilter.new(AlgorithmMatchers.getAlgorithmsMatchers)
algorithmMatcherFilter.filterByNumberOfSamples(10_000)
raise "Wrong answer after filtering by number of samples [10_000]" unless algorithmMatcherFilter.algorithmMatchers.size == 8

algorithmMatcherFilter = AlgorithmMatcherFilter.new(AlgorithmMatchers.getAlgorithmsMatchers)
algorithmMatcherFilter.filterByNumberOfSamples(11_000)
raise "Wrong answer after filtering by number of samples [11_000]" unless algorithmMatcherFilter.algorithmMatchers.size == 8

algorithmMatcherFilter = AlgorithmMatcherFilter.new(AlgorithmMatchers.getAlgorithmsMatchers)
algorithmMatcherFilter.filterByNumberOfSamples(100_000)
raise "Wrong answer after filtering by number of samples [100_000]" unless algorithmMatcherFilter.algorithmMatchers.size == 8

algorithmMatcherFilter = AlgorithmMatcherFilter.new(AlgorithmMatchers.getAlgorithmsMatchers)
algorithmMatcherFilter.filterByNumberOfSamples(101_000)
raise "Wrong answer after filtering by number of samples [101_000]" unless algorithmMatcherFilter.algorithmMatchers.size == 12

########################################################################################################################
algorithmMatcherFilter = AlgorithmMatcherFilter.new(AlgorithmMatchers.getAlgorithmsMatchers)
algorithmMatcherFilter.filterByTextData(TextData.yes)
raise "Wrong answer after filtering by text data [yes]" unless algorithmMatcherFilter.algorithmMatchers.size == 18

algorithmMatcherFilter = AlgorithmMatcherFilter.new(AlgorithmMatchers.getAlgorithmsMatchers)
algorithmMatcherFilter.filterByTextData(TextData.no)
raise "Wrong answer after filtering by text data [no]" unless algorithmMatcherFilter.algorithmMatchers.size == 19

algorithmMatcherFilter = AlgorithmMatcherFilter.new(AlgorithmMatchers.getAlgorithmsMatchers)
algorithmMatcherFilter.filterByTextData(TextData.notRelevant)
raise "Wrong answer after filtering by text data [notRelevant]" unless algorithmMatcherFilter.algorithmMatchers.size == 17

########################################################################################################################
algorithmMatcherFilter = AlgorithmMatcherFilter.new(AlgorithmMatchers.getAlgorithmsMatchers)
algorithmMatcherFilter.filterByLabeledData(LabeledData.yes)
raise "Wrong answer after filtering by labeled data [yes]" unless algorithmMatcherFilter.algorithmMatchers.size == 15

algorithmMatcherFilter = AlgorithmMatcherFilter.new(AlgorithmMatchers.getAlgorithmsMatchers)
algorithmMatcherFilter.filterByLabeledData(LabeledData.no)
raise "Wrong answer after filtering by labeled data [no]" unless algorithmMatcherFilter.algorithmMatchers.size == 14

algorithmMatcherFilter = AlgorithmMatcherFilter.new(AlgorithmMatchers.getAlgorithmsMatchers)
algorithmMatcherFilter.filterByLabeledData(LabeledData.noInfo)
raise "Wrong answer after filtering by labeled data [noInfo]" unless algorithmMatcherFilter.algorithmMatchers.size == 9

########################################################################################################################
algorithmMatcherFilter = AlgorithmMatcherFilter.new(AlgorithmMatchers.getAlgorithmsMatchers)
algorithmMatcherFilter.filter(Prediction.categoryWithUnknownNumberOfCategories, 101_000, TextData.yes, LabeledData.noInfo)
raise "Wrong answer after filtering by all attributes [categoryWithUnknownNumberOfCategories, 101_000, yes, noInfo]" unless algorithmMatcherFilter.algorithmMatchers.size == 2

########################################################################################################################
algorithmMatcherFilter = AlgorithmMatcherFilter.new(AlgorithmMatchers.getAlgorithmsMatchers)
algorithmMatcherFilter.filter(Prediction.categoryWithUnknownNumberOfCategories, 101_000, TextData.yes, LabeledData.no)
raise "Wrong answer after filtering by all attributes [categoryWithUnknownNumberOfCategories, 101_000, yes, no]" unless algorithmMatcherFilter.algorithmMatchers.size == 3

########################################################################################################################
algorithmMatcherFilter = AlgorithmMatcherFilter.new(AlgorithmMatchers.getAlgorithmsMatchers)
algorithmMatcherFilter.filter(Prediction.categoryWithUnknownNumberOfCategories, 101_000, TextData.yes, LabeledData.yes)
raise "Wrong answer after filtering by all attributes [categoryWithUnknownNumberOfCategories, 101_000, yes, noInfo]" unless algorithmMatcherFilter.algorithmMatchers.size == 4
