window.kmeans_main  = function(i,moes, data, subclusters, firstLevel, secondLevel, experiment_id, prefix) {
    /*$('body').append(viewer);
     var dialog = $('#clusters_details');
     dialog.on("closed", function() {
     $('#clusteringModal').foundation('reveal', 'open');
     })
     */
    function openViewer() {
        return function () {
            var clucter_id = this.id.split("s")[0];
            var simulations = this.indexes.join();

            show_cluster_info_modal(clucter_id, simulations);


        }
    }

    function show_cluster_info_modal(cluster_id, simulations) {
        //TO DO: baseurl jest na sztywno, trzeba to przekazać
        var url = "https://localhost:25000/cluster_infos/" + experiment_id + "?cluster_id=" + cluster_id + "&simulations=" + simulations;
        console.log(url);
        var handler = function (data) {
            $('#clusterInfo').html(data);
            $('#clusterInfo').foundation('reveal', 'open');
            $('#clusterInfo').on("closed", function () {
                $('#dendrogramModal').foundation('reveal', 'open');
            })
        }
        $('#clusterInfo').html(window.loaderHTML);
        getWithSession(url, {}, handler);
    }

    /*
     var clusters = [];
     var subclusters = [];
     var subcluster_size;
     var brightness;

     for(var j in data) {
     var color = colors[ j%colors.length ];
     clusters.push({
     y: data[j]["indexes"].length,
     id: 'cluster_' + data[j]["cluster"],
     visible: true,
     indexes: data[j]["indexes"],
     means: data[j]["means"],
     ranges: data[j]["ranges"],
     color: color
     });
     var cluster_size = data[j]["subclusters"].length;
     for(var k in data[j]["subclusters"]){
     subcluster_size = data[j]["subclusters"][k]["indexes"].length;
     brightness = 0.2 - (1.0*k / cluster_size) / 5;
     subclusters.push({
     y: subcluster_size,
     id: 'cluster_' + data[j]["subclusters"][k]['cluster'],
     visible: true,
     indexes: data[j]["subclusters"][k]["indexes"],
     means: data[j]["subclusters"][k]["means"],
     ranges: data[j]["subclusters"][k]["ranges"],
     color: Highcharts.Color(color).brighten(brightness).get()
     });
     }

     }*/
    var error = false;
    var colors = Highcharts.getOptions().colors;
    var clusters = [];
    var subclust = [];
    for (var j in data) {
        var color = colors[j % colors.length];
        clusters.push({
            y: data[j].length,
            id: 'cluster_' + j,
            visible: true,
            indexes: data[j],
            /*  means: data[j]["means"],
             ranges: data[j]["ranges"],*/
            color: color
        });
        var cluster_size = data[j].length;

        for (var k in subclusters[j]) {
            subcluster_size = subclusters[j][k].length;
            console.debug(subcluster_size);
            if (subcluster_size == 0) error = true;
            brightness = 0.2 - (1.0 * k / cluster_size) / 5;
            subclust.push({
                y: subcluster_size,
                id: 'cluster_' + j + 's' + k,
                visible: true,
                indexes: subclusters[j][k],
                /*    means: data[j]["subclusters"][k]["means"],
                 ranges: data[j]["subclusters"][k]["ranges"],*/
                color: Highcharts.Color(color).brighten(brightness).get()
            });
        }
    }
    console.debug(error);
    if (error) {
        $('#kmeans_chart_' + i)[0].remove();
        toastr.error("to many subclusters. Can not divide data.");
    }else {
        var chart = new Highcharts.Chart({
            chart: {
                renderTo: $('#kmeans_chart_' + i + " .chart")[0],
                type: 'pie'
            },
            title: {
                text: JSON.stringify(moes) + ", " + firstLevel + ", " + secondLevel
            },
            plotOptions: {
                pie: {
                    shadow: false,
                    center: ['50%', '50%']
                }
            },
            series: [{
                //name: 'Cluster size',
                data: clusters,
                size: '70%',
                dataLabels: {
                    formatter: function () {
                        return null; //this.y > 5 ? this.point.name : null;
                    }//,
                    //color: 'white',
                    //distance: -30
                },
                point: {
                    events: {
                        click: openViewer(this)
                    }
                }
            }, {
                data: subclust,
                size: '100%',
                innerSize: '70%',
                dataLabels: {
                    formatter: function () {
                        return null; //this.y > 5 ? this.point.name : null;
                    }//,
                    //color: 'white',
                    //distance: -30
                },
                point: {
                    events: {
                        click: openViewer(this)
                    }
                }
            }],
            tooltip: {
                formatter: function () {
                    // console.log(this);
                    return "Cluster size: " + this.point.indexes.length + "<br/><b>Click for details</b>";
                }
            }
        });
    }
};