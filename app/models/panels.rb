class Panels
  attr_reader :methods
  attr_reader :groups
  
  def initialize(stand_alone)
    analysisMethodsConfig = AnalysisMethodsConfig.new
    @methods = analysisMethodsConfig.get_method_names
    @groups = analysisMethodsConfig.get_groups(stand_alone)
  end
end