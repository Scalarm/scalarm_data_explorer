class Prediction

  @@category_known_number_of_categories = :category_known_number_of_categories
  @@category_unknown_number_of_categories = :category_unknown_number_of_categories
  @@quantity = :quantity
  @@structure = :structure
  @@anything = :anything

  def self.category_known_number_of_categories
    @@category_known_number_of_categories
  end

  def self.category_unknown_number_of_categories
    @@category_unknown_number_of_categories
  end

  def self.quantity
    @@quantity
  end

  def self.structure
    @@structure
  end

  def self.anything
    @@anything
  end

end