window.threeD_main = function(i, param_x, param_y, param_z, data) {
    var min_z = data.reduce(function(a, b) { return a <= b[2] ? a : b[2];}, Infinity);
    var max_z = data.reduce(function(a, b) { return a >= b[2] ? a : b[2];}, -Infinity);

    function scale(z, min, max){
        return max-Math.round((z-min_z)/(max_z-min_z)*(max-min));
    }

    var tab = data.map(function(obj){
        var color = 'rgb(' + scale(obj[2], 0, 20) + ', ' + scale(obj[2], 0, 130) + ', ' + scale(obj[2], 0, 255) + ')';
        return {x: obj[0], y: obj[1], z: obj[2],
            color: color,
            marker: {
                states: {
                    hover: {
                        fillColor: color
                    }
                }
        }}});

    //nice feature but causes "udefined is not a function" on loading more than one chart
    // Give the points a 3D feel by adding a radial gradient
    // Highcharts.getOptions().colors = $.map(Highcharts.getOptions().colors, function (color) {
    //     return {
    //         radialGradient: {
    //             cx: 0.4,
    //             cy: 0.3,
    //             r: 0.5
    //         },
    //         stops: [
    //             [0, color],
    //             [1, Highcharts.Color(color).brighten(-0.2).get('rgb')]
    //         ]
    //     };
    // });

    // Set up the chart
	var chart = new Highcharts.Chart({
        chart: {
            renderTo: $('#three_d_chart_'+ i + " .chart")[0],
            margin: 100,
            type: 'scatter',
            options3d: {
                enabled: true,
                alpha: 10,
                beta: 20,
                depth: 250,

                frame: {
                    bottom: { size: 1, color: 'rgba(0,0,0,0.02)' },
                    back: { size: 1, color: 'rgba(0,0,0,0.04)' },
                    side: { size: 1, color: 'rgba(0,0,0,0.06)' }
                }
            }
        },
        plotOptions: {
            series: {
                turboThreshold: tab.length, //enable to plot more than 1000 points (default), with 0 it check every point format, with specific value only the first point is tested and the rest are assumed to be the same format
            },
        },
        title: {
            text: '3d scatter plot'
        },
        subtitle: {
            text: param_x + " - " + param_y + " - " + param_z
        },
        yAxis: {
            title: {
                text: param_y
            }
        },
        xAxis: {
            title: {
                text: param_x
            }
        },
        zAxis: {
            min: min_z,
            max: max_z,
            title: {
                text: param_z
            }
        },
        credits: {
            enabled: false
        },
        legend: {
            enabled: false
        },
        series: [{
            data: tab
        }],
        tooltip: {
            formatter: function(){
                return param_x + ": " + this.x + "<br/>" + param_y + ": " + this.y + "<br>" + param_z + ": " + this.point.z;
            }
        }
    });


    // Add mouse events for rotation
    $(chart.container).bind('mousedown.hc touchstart.hc', function (e) {
        e = chart.pointer.normalize(e);

        var posX = e.pageX,
            posY = e.pageY,
            alpha = chart.options.chart.options3d.alpha,
            beta = chart.options.chart.options3d.beta,
            newAlpha,
            newBeta,
            sensitivity = 5; // lower is more sensitive

        $(document).bind({
            'mousemove.hc touchdrag.hc': function (e) {
                // Run beta
                newBeta = beta + (posX - e.pageX) / sensitivity;
                newBeta = Math.min(100, Math.max(-100, newBeta));
                chart.options.chart.options3d.beta = newBeta;

                // Run alpha
                newAlpha = alpha + (e.pageY - posY) / sensitivity;
                newAlpha = Math.min(100, Math.max(-100, newAlpha));
                chart.options.chart.options3d.alpha = newAlpha;

                chart.redraw(false);
            },
            'mouseup touchend': function () {
                $(document).unbind('.hc');
            }
        });
    });

}
