window.morris_main = function (i, series_to_plot, sorted_parameters_names) {
	var chart = new Highcharts.Chart({
		chart: {
			renderTo: $('#morris_chart_'+ i + " .chart")[0],
			type: 'bar'
		},
		title: {
			text: ''
		},
		xAxis: {
			categories: sorted_parameters_names,
			title: {
				text: null
			}
		},
		yAxis: {
			title: {
				text: 'Normalized sensitivity',
				align: 'high'
			},
			labels: {
				overflow: 'justify'
			}
		},
		plotOptions: {
			bar: {
				dataLabels: {
					enabled: true
				}
			}
		},
		legend: {
			layout: 'vertical',
			align: 'right',
			verticalAlign: 'top',
			floating: true,
			backgroundColor: '#FFFFFF',
			x:-30
		},
		credits: {
			enabled: false
		},
		series: series_to_plot
	})
}
