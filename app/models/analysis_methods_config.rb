require 'json'
include Scalarm::ServiceCore::ParameterValidation

class AnalysisMethodsConfig
  attr_reader :content


  ##
  # read config from file
  def initialize

    file = File.read("config/methods.json")
    @content = JSON.parse(file)
  end


  def get_method_names
    @content["methods"]
  end


  ##
  # return information about method from method's catalog
  def get_groups(stand_alone)
    if stand_alone == 'false' || stand_alone.nil?
      groups = @content["groups"]
    else
      groups = {"basic"=>{"name"=>"Variate analysis", "methods"=>[]},
                "params"=>{"name"=>"Parameters influence", "methods"=>[]}}
    end


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
        raise SecurityError.new('No such group: " + group_name + "(method: " + method_name + ")')
      end
    end
    groups

  end
end