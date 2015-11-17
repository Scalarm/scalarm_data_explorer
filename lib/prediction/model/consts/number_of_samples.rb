class NumberOfSamples

  @@less_than_50 = :less_than_50
  @@more_than_50_less_than_10k = :more_than_50_less_than_10k
  @@more_than_50_less_than_100k = :more_than_50_less_than_100k
  @@more_than_10k = :more_than_10k
  @@more_than_100k = :more_than_100k

  def self.less_than_50
    @@less_than_50
  end

  def self.more_than_50_less_than_10k
    @@more_than_50_less_than_10k
  end

  def self.more_than_50_less_than_100k
    @@more_than_50_less_than_100k
  end

  def self.moreThan10k
    @@more_than_10k
  end

  def self.more_than_100k
    @@more_than_100k
  end

end