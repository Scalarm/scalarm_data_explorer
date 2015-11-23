class AlgorithmType

  @@classification = :classification
  @@clustering = :clustering
  @@regression = :regression
  @@dimensionalityReduction = :dimensionalityReduction
  @@unknown = :unknown

  def self.classification
    @@classification
  end

  def self.clustering
    @@clustering
  end

  def self.regression
    @@regression
  end

  def self.dimensionalityReduction
    @@dimensionalityReduction
  end

  def self.unknown
    @@unknown
  end

end