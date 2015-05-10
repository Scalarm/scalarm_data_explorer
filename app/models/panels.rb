class Panels
    
  attr_reader :methods
  attr_reader :groups
  def initialize

  	file = File.read("config/methods.json")
  	#Rails.logger.info file
  	content = JSON.parse(file)
	  #Rails.logger.info content
    @methods = content["methods"]
    @groups = content["groups"]
  #   @methods.each do |name|
  #   # //for(var i in methods){
  #   #var name = methods[i];
  #     info = require("./visualisation_methods/" + name + "/plugin.js").info;
  #     group_name = info.group;
  #     group = groups[group_name];
  #     if group 
  #         if group.methods 
  #             group.methods.push(info);
        
  #          else 
  #             group.methods = [info];
  #         end
    
  #     else
  #         raise ExceptionType, "No such group: " + group_name + "(method: " + name + ")";
  #     end
  # end
	end

end