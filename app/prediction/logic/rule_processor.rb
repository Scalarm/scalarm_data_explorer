require_relative 'file_reader'
require_relative 'hints_matcher'
require_relative 'algorithm_matcher_filter'
require_relative '../model/notes'
require_relative '../model/consts/prediction'
require_relative '../model/consts/labeled_data'
require_relative '../model/result_aggregator'


class RuleProcessor

=begin
  def initialize(fileReader)
    @fileReader = fileReader
  end
=end

=begin
  def suggest (prediction, labeledData)
    Rails.logger.debug(@fileReader)
    RuleProcessor.suggest(prediction, @fileReader.lines, transformTextDataInfo(@fileReader.textData), labeledData)
  end

  def transformTextDataInfo(textData)
    textData ? LabeledData.yes : LabeledData.no
  end

  def suggest (fileName, prediction, labeledData)
    fileReader = FileReader.new(fileName)
    RuleProcessor.suggest(prediction, fileReader.lines, transformTextDataInfo(fileReader.textData), labeledData)
  end
=end

  def suggest (prediction, lines, text_data, labeled_data)
    hints = HintsMatcher.new(prediction, lines, text_data, labeled_data).gatherHints
    algorithms = AlgorithmMatcherFilter.new(AlgorithmMatchers.getAlgorithmsMatchers).filter(prediction, lines, text_data, labeled_data)
    ResultAggregator.new(hints, algorithms, Notes.getGeneralNotes)
  end

end
