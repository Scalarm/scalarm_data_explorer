class AlgorithmType

  @@classification = :classification
  @@clustering = :clustering
  @@regression = :regression
  @@dimensionalityReduction = :dimensionality_reduction
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

  def self.dimensionality_reduction
    @@dimensionalityReduction
  end

  def self.unknown
    @@unknown
  end

end