window.lindev_main = function(i, param_x_label, param_y_label, data) {
    var chart = new Highcharts.Chart({
        chart: {
            zoomType: 'xy',
            renderTo: $('#lindev_chart_'+ i + " .chart")[0]
        },
        credits: {
            enabled: false
        },
        title: {
            text: "Line chart - " + param_x_label + " vs " + param_y_label
        },
        xAxis: {
            title: {
                text: param_x_label
            }
        },
        yAxis: {
            title: {
                text: param_y_label
            }
        },
        tooltip: {
            shared: true
        },
        series: [{
            name: param_y_label + " (mean)",
            data: data[0],
            tooltip: {
                pointFormat: '<span style="font-weight: bold; color: {series.color}">{series.name}</span>: <b>{point.y:.1f}</b> '
            }
        }, {
            name: 'series stddev',
            type: 'errorbar',
            data: data[1],
            tooltip: {
                pointFormat: '(std dev range: {point.low:.3f} - {point.high:.3f})<br/>'
            }
        }]
    });
};
