window.boxplot_main = function(i, param_x, param_y, data, categories, outliers, mean) {
    if($("#boxplotModal").length == 0) {
        create_chart_div('boxplot', i);
    }

    var chart = new Highcharts.Chart({
        chart: {
            type: 'boxplot',
            renderTo: $('#boxplot_chart_'+ i + " .chart")[0]
        },

        tooltip: {
            positioner: function(boxWidth, boxHeight, point) {
                return {
                    x: point.plotX + 80,
                    y: point.plotY + 50
                };
            },

            formatter: function(){
                var x = categories.indexOf(this.x);

                for(var k = 0; k < outliers.length; k++){
                    if(outliers[k][0] == x && outliers[k][1] == this.y){
                        return 'Outlier: ' + this.x + ', ' + this.y;
                    }
                }

                var data_for_class = data[categories.indexOf(this.x)];

                var tooltip = param_x + " = " + this.x;
                tooltip +=  "<br/><b>Statistics for " + param_y + ":</b>"
                tooltip += '<br/><>Largest non-outlier: ' + data_for_class[4];
                tooltip  += '<br/><>Upper quartile: ' + data_for_class[3];
                tooltip += '<br/><>Median: ' + data_for_class[2];
                tooltip += '<br/><>Lower quartile: ' + data_for_class[1];
                tooltip += '<br/><>Smallest non-outlier: ' + data_for_class[0];
                return tooltip;
            }
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
                value: mean,
                color: 'red',
                width: 1,
                label: {
                    text: "Mean: " + (Math.round(mean * 100)/100).toFixed(2),
                    align: 'right',
                    style: {
                        color: 'red',
                        y: 12,
                        x: 0
                    }
                }
            }]
        },

        plotOptions: {
            boxplot: {
                fillColor: '#6CD',
                lineWidth: 3,
                medianColor: '#0C5DA5',
                medianWidth: 4,
                stemColor: '#0B478B',
                stemDashStyle: 'dash',
                stemWidth: 2,
                whiskerColor: '#0B478B',
                whiskerLength: '20%',
                whiskerWidth: 4,
            }
        },

        series: [{
            name: "Statistics for <em>" + param_y + "</em>:",
            data: data
        }, {
            name: 'Outlier',
            color: Highcharts.getOptions().colors[5],
            type: 'scatter',
            data: outliers,
            marker: {
                fillColor: 'white',
                lineWidth: 1,
                lineColor: Highcharts.getOptions().colors[0]
            },
            tooltip: {
                pointFormat: "<em>" + param_y + "</em> = {point.y}"
            }
        }]

    });

};
