class Algorithm

  attr_reader :name, :type, :description

  def initialize(name, type, description)
    @type = type
    @name = name
    @description = description
  end

end