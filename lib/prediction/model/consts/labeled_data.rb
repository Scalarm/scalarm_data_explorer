class LabeledData

  @@yes = :yes
  @@no = :no
  @@anything = :anything

  def self.yes
    @@yes
  end

  def self.no
    @@no
  end

  def self.no_info
    @@anything
  end

end