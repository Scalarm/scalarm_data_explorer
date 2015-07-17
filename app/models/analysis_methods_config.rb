require 'json'
class AnalysisMethodsConfig
  attr_reader :content


  def initialize
    #Rails.logger.debug("INITTTT")
    file = File.read("config/methods.json")
    @content = JSON.parse(file)
    #Rails.logger.debug(@content)

  end


  def get_method_names
    @content["methods"]

  end
  def get_groups
    groups = @content["groups"]
    methods = get_method_names
    methods.each do |method_name|
      json = File.read("app/visualisation_methods/#{method_name}/info.json")
      info = JSON.parse(json)

      group_name = info["group"]
      group = groups[group_name]
      if group
        if group["methods"]
          group["methods"] << info
        else
          group["methods"] = [info]
        end
      else
        raise "No such group: " + group_name + "(method: " + method_name + ") "
      end
    end
    groups

  end
end