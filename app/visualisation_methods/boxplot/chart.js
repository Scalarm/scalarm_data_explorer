window.boxplot_main = function(i, param_x, param_y, data, categories, outliers) {
    var chart = new Highcharts.Chart({


        chart: {
            type: 'boxplot',
            renderTo: $('#boxplot_chart_'+ i + " .chart")[0]
        },

        title: {
            text: "Box-plot - " + param_y + " by " + param_x
        },

        legend: {
            enabled: false
        },

        xAxis: {
            categories: categories,
            title: {
                text: param_x
            }
        },

        yAxis: {
            title: {
                text: param_y
            },
            plotLines: [{
                value: 932,
                color: 'red',
                width: 1,
                label: {
                    text: 'Theoretical mean: 932',
                    align: 'center',
                    style: {
                        color: 'gray'
                    }
                }
            }]
        },

        series: [{
            name: "Statistics for <em>" + param_y + "</em>:",
            data: data,
            tooltip: {
                headerFormat: "<em>" + param_x + "</em>" + " = {point.key}<br/>"
            }
        }, {
            name: 'Outlier',
            color: Highcharts.getOptions().colors[0],
            type: 'scatter',
            data: outliers,
            marker: {
                fillColor: 'white',
                lineWidth: 1,
                lineColor: Highcharts.getOptions().colors[0]
            },
            tooltip: {
                pointFormat: 'Observation: {point.y}'
            }
        }]

    });

};
