class Panels
    
  attr_reader :methods
  attr_reader :groups
  def initialize(using_em)
    analysisMethodsConfig = AnalysisMethodsConfig.new
    @methods = analysisMethodsConfig.get_method_names
    @groups = analysisMethodsConfig.get_groups(using_em)
	end

end