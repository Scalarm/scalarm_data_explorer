require 'json'
include Scalarm::ServiceCore::ParameterValidation

class AnalysisMethodsConfig
  attr_reader :content

  ##
  # read config from file
  def initialize
    @content = JSON.parse(File.read(File.join(Rails.root, 'config', 'methods.json')))
  end

  def get_method_names
    @content['methods']
  end

  ##
  # return information about method from method's catalog
  def get_groups(standalone)
    groups = if standalone
               JSON.parse(File.read(File.join(Rails.root, 'config', 'standalone_methods.json')))
             else
               @content['groups']
             end

    methods = get_method_names
    methods.each do |method_name|
      info = JSON.parse(File.read(File.join(Rails.root, 'app', 'visualisation_methods', method_name, 'info.json')))

      group_name = info["group"]
      group = groups[group_name]
      if group
        if group["methods"]
          group["methods"] << info
        else
          group["methods"] = [info]
        end
      else
        raise SecurityError.new("No such group: '#{group_name}' (method: '#{method_name}')")
      end
    end

    groups
  end

end