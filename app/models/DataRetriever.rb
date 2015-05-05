class DataRetriever

	COLLECTION_NAME = "experiment_instances_";
	CAPPED_COLLECTION_NAME = "experiment_progress_notifications";
	mongo = require('mongodb');
	client = mongo.MongoClient;
	crypto = require('crypto');
	#return array not function 
	def GetData(id, convertData)

		filter = {is_done: true, is_error: {'$exists': false}};
		fields = {fields: {arguments: 1, values: 1, result: 1}};
		Array = db.collection(COLLECTION_NAME+id).find(filter, fields).toArray();

		if array.length==0
					raise "No such experiment or no runs done";
		end
				
		args = array[0].arguments.split(',');

		array = array.map do |data|
				values = data.values.split(',');

					new_args = {};
					for(var i = 0; i<args.length; i++){
						new_args[args[i]] = parseFloat(values[i]); //parseInt
					}

					data.arguments = new_args;
					delete data.values;
					data.result.each do |key|
					#for(var key in data.result){
                    	#if(!Number.isNaN(parseFloat(data.result[key]))){
                        #	data.result[key] = parseFloat(data.result[key]);
                        #}

                    end

					return data;
			end

				mins = [];
				maxes = [];
				args.each do |i|
				#for (i in args) {
					mins[args[i]] = min(array, args[i]);
					maxes[args[i]] = max(array, args[i]);
				
				#console.timeEnd("[DB]");
				#convertData(array,args,mins,maxes);
			});
		};
	end


end