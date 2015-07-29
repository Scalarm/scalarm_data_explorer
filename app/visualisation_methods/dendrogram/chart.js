dendrogram_main = function(i, param_x, data, experiment_id, prefix) {


    var root = JSON.parse(data);

    var si = 30;
    var radius = ($("#dendrogramModal").width()/2)-40;
    var margin = 25;
    var cluster = d3.layout.cluster()
        .size([360, radius-margin])
        .separation(function(a, b) { return (a.parent == b.parent ? 1 : 2) / a.depth; });

    var diagonal = d3.svg.diagonal.radial()
        .projection (function(d) { return [d.y, d.x / 180* Math.PI];});

    var svg = d3.select("#dendrogram_chart_form").append("svg")
        .attr("width",2*radius)
        .attr("height",2*radius)
        .append("g")
        .attr("transform","translate("+radius + "," + radius + ")");

    var color = d3.scale.category20();
    var nodes = cluster.nodes(root);
    var links = cluster.links(nodes);
    var link = svg.selectAll(".link")
        .data(links)
        .enter().append("path")
        .attr("class","link")
        .attr("d", diagonal)
        .on({
            "click":  function(d) {
                alert("link") }
        })
        .style("stroke-width", function(d) {
            if (d.source.depth > 9) return 2;
            else
                return (10-d.source.depth); })
        .style("stroke", function(d) { return color(d.source.depth); });






    var node = svg.selectAll(".node")
        .data(nodes)
        .enter().append("g")
        .attr("class","node")
        .attr("transform", function(d) { return "rotate(" + (d.x - 90) + ")translate(" + d.y + ")"; });

    node.append("circle")
        .attr("cursor", "pointer")
        .style("fill", function(d){ if (!d.parent)return "#1F77B4"})
        .style("stroke", function(d){ if (!d.parent)return "#222"})
        .attr("r", function(d) {
            if (d.depth > 6) return 6;
            return (12-d.depth)
        })

        .on({
            "mouseover": function(d) {
                //highlight([d.id]);
                //d3.select(d).classed("highlighted", true);
                (d).classed("highlighted", true);
            },

            "mouseout": function(d,i) {
                if (d3.selectAll("svg path").empty()) {
                    unhighlight();
                }
            },

            "click":  function(d) {
                d.coc = list_of_children.size;

                if (d.children) {
                    // TODO: trzeba zmienić prefix - przekazać baseurl
                    var url = "https://localhost:25000/cluster_infos/" + experiment_id + "?cluster_id=" + d.id + "&simulations=" + list_of_children(d).toString();

                    var handler = function(data) {
                        $('#clusterInfo').html(data);
                        $('#clusterInfo').foundation('reveal', 'open');
                        $('#clusterInfo').on("closed", function() {
                            $('#dendrogramModal').foundation('reveal', 'open');
                        })
                    }
                    $('#clusterInfo').html(window.loaderHTML);
                    getWithSession(url, {}, handler);


                }
                else {
                    if (/^cl \d+$/.test(d.id)) {
                        var cluster_id = d.id.replace( /\D+/g, '');
                        var url = "https://localhost:25000/cluster_infos/" + experiment_id + "?cluster_id=" + cluster_id + "&simulations=" + d.simulations;

                        var handler = function(data) {
                            $('#clusterInfo').html(data);
                            $('#clusterInfo').foundation('reveal', 'open');
                            $('#clusterInfo').on("closed", function() {
                                $('#dendrogramModal').foundation('reveal', 'open');
                            })
                        }
                        $('#clusterInfo').html(window.loaderHTML);
                        getWithSession(url, {}, handler);

                    }else {
                        var url = prefix + "/experiments/" + experiment_id + "/simulations/"+d.id;

                        var handler = function(data) {
                            $('#extension-dialog').html(data);
                            $('#extension-dialog').foundation('reveal', 'open');
                            $('#extension-dialog').on("closed", function() {
                                $('#dendrogramModal').foundation('reveal', 'open');
                            })
                        }
                        $('#extension-dialog').html(window.loaderHTML);
                        getWithSession(url, {}, handler);
                    }

                }
            }



        });


    node.append("text")
        .style("font-size", "15px")
        .attr("cursor", "pointer")
        .attr("dy", ".31em")
        .attr("text-anchor", function(d) { return d.x < 180 ? "start" : "end"; })
        .attr("transform", function(d) { return d.x < 180 ? "translate(8)" : "rotate(180)translate(-8)"; })
        .text(function(d) { if(!d.children) return d.id; }) // wyĹwi
        .on({
            "mouseover": function() {
            },

            "mouseout": function() {
            },

            "click":  function(d) {
                var url = prefix + "/experiments/" + experiment_id + "/simulations/"+d.id;

                var handler = function(data) {
                    $('#extension-dialog').html(data);
                    $('#extension-dialog').foundation('reveal', 'open');
                    $('#extension-dialog').on("closed", function() {
                        $('#dendrogramModal').foundation('reveal', 'open');
                    })
                }

                $('#extension-dialog').html(window.loaderHTML);
                getWithSession(url, {}, handler);
            }
        });

    function list_of_children_requrency(d, list2) {
        var c = 0;
        if (/^cl \d+$/.test(d.id)) {
            list2.push(d.simulations);
        }
        for (ch in d.children)  {
            if (/^cl \d+$/.test(d.children[ch].id)) {
                list2.push(d.children[ch].simulations);
            }
            else {
                if (!d.children[ch].children) {
                    list2.push(d.children[ch].id);
                    list2.size++;
                }
                else {
                    list_of_children_requrency(d.children[ch], list2);
                }
            }
        }
    }

    function list_of_children(d) {
        var list = [];
        list_of_children_requrency(d, list);
        return list;
    }

    function unhighlight() {
        d3.selectAll("circle").classed("highlighted", false);
    }

    function highlight(ids) {
        // First unhighlight all the circles.
        unhighlight();

        // Find the circles that have an id
        // in the array of ids given, and
        // highlight those.
        d3.selectAll("circle").filter(function(d, i) {
            return ids.indexOf(d.id) > -1;
        })
            .classed("highlighted", true);
    }



    window.onresize = function() {

    };





    renderTo
        :
        $('#chart_' + i + " .chart")[0]


};