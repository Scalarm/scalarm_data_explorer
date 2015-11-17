class RuleProcessor

  def suggest (prediction, lines, text_data, labeled_data)
    hints = HintsMatcher.new(prediction, lines, text_data, labeled_data).gatherHints
    algorithms = AlgorithmMatcherFilter.new(AlgorithmMatchers.get_algorithms_matchers).filter(prediction, lines, text_data, labeled_data)
    ResultAggregator.new(hints, algorithms, Notes.get_general_notes)
  end

end
