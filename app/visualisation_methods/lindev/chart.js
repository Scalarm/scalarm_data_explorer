window.lindev_main = function(i, notationx, notationy, param_x, param_y, data) {

    var chart = new Highcharts.Chart({
        chart: {
            zoomType: 'xy',
            renderTo: $('#chart_'+ i + " .chart")[0]
        },
        credits: {
            enabled: false
        },
        title: {
            text: "Line chart - " + param_x + " vs " + param_y
        },
        xAxis: {
            labels:{
                formatter: function(){
                    if (notationx == "scientific")
                        return this.value.toExponential(2);
                    else
                        return this.value;
                }
            },
            title: {
                text: param_x
            }
        },
        yAxis: {
            labels:{
                formatter: function(){
                    if (notationy == "scientific")
                        return this.value.toExponential(2);
                    else
                        return this.value;
                }
            },
            title: {
                text: param_y
            }
        },
        tooltip: {
            shared: true
        },
        series: [{
            name: param_y + " (mean)",
            data: data[0],
            tooltip: {
                pointFormat: '<span style="font-weight: bold; color: {series.color}">{series.name}</span>: <b>{point.y:.1f}</b> '
            }
        }, {
            name: 'series stddev',
            type: 'errorbar',
            data: data[1],
            tooltip: {
                pointFormat: '(std dev range: {point.low:.3f}-{point.high:.3f})<br/>'
            }
        }]
    });
};
