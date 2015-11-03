window.sensitivity_main = function (i, series_to_plot, sorted_parameters_names, method_name) {

	switch (method_name) {
		case "morris":

			var chart = new Highcharts.Chart({
				chart: {
					renderTo: $('#sensitivity_chart_'+ i + " .chart")[0],
					type: 'bar'
				},
				title: {
					text: null
				},
				xAxis: {
					categories: sorted_parameters_names,
					title: {
						text: null
					},
					labels: {
						rotation: -45
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
					borderColor: '#CCC',
					borderWidth: 1,
					floating: true,
					backgroundColor: '#FFFFFF',
					x:-30
				},
				credits: {
					enabled: false
				},
				series: series_to_plot
			})

			break;

		case "fast":

			var chart = new Highcharts.Chart({
				chart: {
					renderTo: $('#sensitivity_chart_'+ i + " .chart")[0],
					type: 'column'
				},
				title: {
					text: null
				},
				xAxis: {
					categories: sorted_parameters_names,
					title: {
						text: '<b>Parameters</b>'
					},
				},
				yAxis: {
					min: 0,
						title: {
						text: null
					},
					stackLabels: {
						enabled: true,
							style: {
							fontWeight: 'bold',
								color: 'gray'
						}
					}
				},
				legend: {
					align: 'right',
					x: -30,
					verticalAlign: 'top',
					floating: true,
					borderColor: '#CCC',
					borderWidth: 1,
					shadow: false
				},
				tooltip: {
					formatter: function () {
						return '<b>' + this.x + '</b><br/>' +
							this.series.name + ': ' + this.y + '<br/>' +
							'Total effect: ' + this.point.stackTotal;
					}
				},
				plotOptions: {
					column: {
						stacking: 'normal',
							dataLabels: {
							enabled: true,
								color: 'white',
								style: {
								textShadow: '0 0 3px black'
							}
						}
					}
				},
				series: series_to_plot,
				credits: {
					enabled: false
				}
			})


			break;

		default:
			toastr.error("No visualization for specific method - \"" + method_name + "\"");
			break;
	}


}
