require_relative 'hints_matcher'
require_relative 'algorithm_matcher_filter'
require_relative '../model/notes'
require_relative '../model/consts/prediction'
require_relative '../model/consts/labeled_data'
require_relative '../model/result_aggregator'


class RuleProcessor

  def suggest (prediction, lines, text_data, labeled_data)
    hints = HintsMatcher.new(prediction, lines, text_data, labeled_data).gatherHints
    algorithms = AlgorithmMatcherFilter.new(AlgorithmMatchers.get_algorithms_matchers).filter(prediction, lines, text_data, labeled_data)
    ResultAggregator.new(hints, algorithms, Notes.get_general_notes)
  end

end
