class NumberOfSamples

  @@lessThan50 = :lessThan50
  @@moreThan50LessThan10k = :moreThan50LessThan10k
  @@moreThan50LessThan100k = :moreThan50LessThan100k
  @@moreThan10k = :moreThan10k
  @@moreThan100k = :moreThan100k

  def self.lessThan50
    @@lessThan50
  end

  def self.moreThan50LessThan10k
    @@moreThan50LessThan10k
  end

  def self.moreThan50LessThan100k
    @@moreThan50LessThan100k
  end

  def self.moreThan10k
    @@moreThan10k
  end

  def self.moreThan100k
    @@moreThan100k
  end

end