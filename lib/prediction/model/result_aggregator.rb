class ResultAggregator

  attr_reader :hints, :algorithms, :notes

  def initialize(hints, algorithms, notes)
    @hints = hints
    @algorithms = algorithms
    @notes = notes
  end

end