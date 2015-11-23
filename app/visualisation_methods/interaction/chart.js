window.interaction_main = function(i, param_x, param_y, data) {
	if($("#interactionModal").length == 0) {
		create_chart_div('interaction', i);
	}
	var chart = new Highcharts.Chart({
		chart: {
			renderTo: $('#interaction_chart_'+ i + " .chart")[0]
		},
		title: {
			text: "Interaction chart"
		},
		xAxis: {
			title: {
				text: param_x
			}
		},
		yAxis: {
			title: {
				text: "Average effect"
			}
		},
		credits:{
			enabled: false
		},
		legend: {
			layout: 'vertical'
		},
		series: [{
			name: "Low " + param_y,
			data: [{
				name: "Point 1",
				x: data[param_x].domain[0],
				y: data.effects[0]
			}, {
				name: "Point 2",
				x: data[param_x].domain[1],
				y: data.effects[1]
			}]
		}, {
			name: "High " + param_y,
			data: [{
				name: "Point 3",
				x: data[param_x].domain[0],
				y: data.effects[2]
			}, {
				name: "Point 4",
				x: data[param_x].domain[1],
				y: data.effects[3]
			}]
		}]
	})
}
