class Prediction

  @@categoryWithKnownNumberOfCategories = :categoryWithKnownNumberOfCategories
  @@categoryWithUnknownNumberOfCategories = :categoryWithUnknownNumberOfCategories
  @@quantity = :quantity
  @@structure = :structure
  @@noInfo = :noInfo

  def self.categoryWithKnownNumberOfCategories
    @@categoryWithKnownNumberOfCategories
  end

  def self.categoryWithUnknownNumberOfCategories
    @@categoryWithUnknownNumberOfCategories
  end

  def self.quantity
    @@quantity
  end

  def self.structure
    @@structure
  end

  def self.noInfo
    @@noInfo
  end

end