class Panels
    
  attr_reader :methods
  attr_reader :groups
  def initialize
    #wyszukaj info z folderu visualsation_methods
  	file = File.read("config/methods.json")

  	content = JSON.parse(file)

    @methods = content["methods"]
    @groups = content["groups"]

    @methods.each do |method_name|
      json = File.read("app/visualisation_methods/#{method_name}/info.json")
      info = JSON.parse(json)

      group_name = info["group"]
      group = @groups[group_name]
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

	end

end