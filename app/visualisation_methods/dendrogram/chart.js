dendrogram_main = function(i, param_x, data, experiment_id, prefix) {


    var root = JSON.parse(data);

    var si = 30;
    var radius = ($("#dendrogramModal").width()/2)-40;
    var margin = 75;
    var cluster = d3.layout.cluster()
        .size([360, radius-margin])
        .separation(function(a, b) { return (a.parent == b.parent ? 1 : 1) / a.depth; });

    var diagonal = d3.svg.diagonal.radial()
        .projection (function(d) { return [d.y, d.x / 180* Math.PI];});

    var svg = d3.select("#dendrogram_chart_form").append("svg")
        .attr("width",2*radius)
        .attr("height",2*radius)
        .append("g")
        .attr("transform","translate("+radius + "," + radius + ")");

    var color = d3.scale.category20();
    var scale_for_circle_size = d3.scale.linear()
        .range([5, 12])
        .domain([0, list_of_children(root).length]);
    var scale_for_link_size = d3.scale.linear()
        .range([2, 9])
        .domain([12, 0]);

    var nodes = cluster.nodes(root);
    var links = cluster.links(nodes);
    var path_to_root = [ 924, 961];
    var link = svg.selectAll(".link")
        .data(links)
        .enter().append("path")
        .attr("class","link")
        .attr("d", diagonal)
        .style("stroke", function(d) { return color(d.source.depth); })
        .style("stroke-width", function(d) { return scale_for_link_size(d.source.depth); })
        .on({
            "click":  function(d) {
                alert("link: " + d.source.id + ", " + d.target.id);

            }


        });

    var node = svg.selectAll(".node")
        .data(nodes)
        .enter().append("g")
        .attr("class","dendrogram-node")
        .attr("transform", function(d) { return "rotate(" + (d.x - 90) + ")translate(" + d.y + ")"; });

    node.append("circle")
        .attr("class", function(d) {
            return set_node_default_color(d);
        })
        .style("stroke", function(d){ if (!d.parent)return "#222"})
        .attr("r", function(d) {
            return scale_for_circle_size(list_of_children(d).length)
            //if (d.depth > 6) return 6;
            //return (12-d.depth)
        })

        .on({
            "mouseover": function(d) {
                //d3.select( this ).attr("class", "highlighted");
                $(this).next().attr("class", "highlighted");
                highlight_path_to_root(d);

            },

            "mouseout": function(d) {
                unhighlight_path_to_root(d);
                $(this).next().attr("class", "text");
            },

           "click":  function(d) {
               if (d.children) {
                   show_cluster_info_modal(d.id, list_of_children(d).toString());
               }
               else {
                   if (/^cl \d+$/.test(d.id)) {
                       var cluster_id = d.id.replace( /\D+/g, '');
                       show_cluster_info_modal(cluster_id, d.simulations);

                   }else {
                       show_simulation_details_modal(d.id);
                   }
               }
           }
        });

    node.append("text")
        .attr("text-anchor", function(d) { return d.x < 180 ? "start" : "end"; })
        .attr("transform", function(d) { return d.x < 180 ? "translate(8)" : "rotate(180)translate(-8)"; })
        .text(function(d) { if(!d.children) return d.id; }) // wyĹwi
        .on({
            "mouseover": function(d) {
                //var n = svg.selectAll("circle").filter(function (a) { return a.id === d.id; })
                  //  .style("fill", "red");
                //var m = svg.selectAll(".node").filter(function (a) { return a.id === d.id; });
                $(this).prev().attr("class", "highlighted");
                d3.select( this ).attr("class", "highlighted");
                highlight_path_to_root($(this).prev());

            },

            "mouseout": function() {
                d3.select( this ).attr("class", "text");
                set_node_color($(this).prev());

            },

            "click":  function(d) {
                if (/^cl \d+$/.test(d.id)) {
                    var cluster_id = d.id.replace( /\D+/g, '');
                    show_cluster_info_modal(cluster_id, d.simulations);

                }else {
                    show_simulation_details_modal(d.id);
                }
            }
        });

    function highlight_path_to_root(checked_node) {
        var tmp = checked_node;
        while (tmp.parent) {
            link.filter(function (d) { return d.target === tmp; })
                .style("stroke", "orange");

            svg.selectAll("circle").filter(function (d) { return d.id === tmp.id; })
                .attr("class", "highlighted");
            tmp = tmp.parent;
        }




    };

    function unhighlight_path_to_root(checked_node) {
        var tmp = checked_node;
        while (tmp.parent) {
            link.filter(function (d) { return d.target === tmp; })
                .style("stroke", function(d) { return color(d.source.depth); });
            svg.selectAll("circle").filter(function (d) { return d.id === tmp.id; })
                .attr("class", function(d){
                    return set_node_default_color(d);
                });
            tmp = tmp.parent;
        }
    };

    function list_of_children_requrency(d, list2) {
        var c = 0;
        if (/^cl \d+$/.test(d.id)) {
            var array = d.simulations.split(",");
            list2 = array.reduce( function(coll,item){
                coll.push( item );
                return coll;
            }, list2 );
        }
        else
        for (ch in d.children)  {
            if (/^cl \d+$/.test(d.children[ch].id)) {
                var array = d.children[ch].simulations.split(",");
                list2 = array.reduce( function(coll,item){
                    coll.push( item );
                    return coll;
                }, list2 );
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

    function show_simulation_details_modal(simulation_id) {
        var url = prefix + "/experiments/" + experiment_id + "/simulations/" + simulation_id;

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

    function show_cluster_info_modal(cluster_id, simulations) {
        //TO DO: baseurl jest na sztywno, trzeba to przekazać
        var url = "https://localhost:25000/cluster_infos/" + experiment_id + "?cluster_id=" + cluster_id + "&simulations=" + simulations;

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

    function set_node_color(d) {
        if (!d.parent) {
            d.attr("class", "root");
        }
        else if (!d.children && !(/^cl \d+$/.test(d.id))) {
            d.attr("class", "cluster");
        }
        else if (!d.children) {
            d.attr("class", "simulation");
        }
        else d.attr("class", "cluster");
    }

    function set_node_default_color(d) {
        if (!d.parent) {
           return "root";
        }
        else if (!d.children && !(/^cl \d+$/.test(d.id))) {
            return "cluster";
        }
        else if (!d.children) {
           return "simulation";
        }
        else return "cluster";
    }





    //window.onresize = function() {

    //};

    //window.addEventListener('resize', function(){alert("resize");}, true);

    //d3.select(window).on('resize', resize);

    //function resize() {
    //    alert("RS");
    //}




    renderTo
        :
        $('#chart_' + i + " .chart")[0]


};