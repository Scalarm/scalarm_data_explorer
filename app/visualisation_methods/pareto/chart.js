window.pareto_main = function (i, data) {
	max = data.reduce(function(prev,cur){
		if(prev.value<cur.value) return cur;
		else return prev;
	});

	var total_sum = 0;
	data.map(function(e){ total_sum += e.value;})

	var chart = new Highcharts.Chart({
		chart: {
			renderTo: $('#pareto_chart_'+ i + " .chart")[0],
			type: 'bar'
		},
		plotOptions: {
			series: {
				shadow:false,
				borderWidth:0,
				dataLabels:{
					enabled:true,
					formatter:function() {
						var percent_value = (this.y / total_sum) * 100;
						return Highcharts.numberFormat(percent_value) + '%';
					}
				}
			}
		},
		title: {
			text: "Pareto chart"
		},
		xAxis: {
			categories: data.map(function(e){ return e.name;}),
			title: {
				text: "Parameters"
			}
		},
		yAxis: {
			min: 0,
			tickInterval: .05 * total_sum,
			title: {
				text: "Average effect"
			},
			plotLines: [{
	            color: '#335577',
	            width: 2,
	            value: .8 * max.value,
	            dashStyle: "dash"
	        }],
			labels: {
				formatter:function() {
					var percent_value = (this.value / total_sum) * 100;
					return Highcharts.numberFormat(percent_value,0,',') + '%';
				}
			}
		},
		credits: {
			enabled: false
		},
        legend: {
        	enabled: false
        },
		series: [{
			name: "Effect",
			data: data.map(function(e){ return e.value; })
		}]
	})
}
