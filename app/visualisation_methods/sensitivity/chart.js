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
					align: 'right',
					x: -30,
					verticalAlign: 'top',
					floating: true,
					borderColor: '#CCC',
					borderWidth: 1,
					shadow: false
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


		case "pcc":

			var chart = new Highcharts.Chart({
				chart: {
					renderTo: $('#sensitivity_chart_'+ i + " .chart")[0],
					zoomType: 'xy'
				},
				title: {
					text: null
				},
				xAxis: [{
					categories: sorted_parameters_names
				}],
				yAxis: [{
					labels: {
						format: '{value}',
						style: {
							color: Highcharts.getOptions().colors[1]
						}
					},
					title: {
						text: null,
						style: {
							color: Highcharts.getOptions().colors[1]
						}
					}
				}],

				tooltip: {
					shared: true
				},

				series: [{
					name: 'Partial Rank Correlation Coefficients',
					type: 'scatter',
					data: series_to_plot["scatter_data"],
					tooltip: {
						pointFormat: '<span style="font-weight: bold; color: {series.color}">Partial Rank Correlation Coefficient</span>: <b>{point.y:.1f}</b> '
					}
				}, {
					name: 'PRCC error',
					type: 'errorbar',
					data: series_to_plot["error_data"],
					tooltip: {
						pointFormat: '(error range: {point.low}-{point.high})<br/>'
					}
				}],
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
