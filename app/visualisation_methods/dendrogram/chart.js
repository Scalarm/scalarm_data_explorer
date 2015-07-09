dendrogram_main = function(i, param1, data, experiment_id, prefix) {
    var sessionGetJSON = function(url, params, onSuccess, onError) {
        return $.ajax({
            // dataType: "json",
            url: url,
            xhrFields: {
                withCredentials: true
            },
            success: onSuccess,
            error: (onError && onError()) || function(jqXHR, textStatus, errorThrown) {
                console.log("Error on request to " + url + ": " + textStatus + " " + errorThrown);
            }
        });
    };

    root = JSON.parse(data);

    var si = 30;
    var radius = 440;
    var margin = 5;
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
    alert(nodes.size);
    var link = svg.selectAll(".link")
        .data(links)
        .enter().append("path")
        .attr("class","link")
        .attr("d", diagonal)
        .on({
            "click":  function(d) {
                alert("link") }
        })
        .style("stroke", function(d) { return color(d.source.depth); });



    var node = svg.selectAll(".node")
        .data(nodes)
        .enter().append("g")
        .attr("class","node")
        .attr("transform", function(d) { return "rotate(" + (d.x - 90) + ")translate(" + d.y + ")"; });

    node.append("circle")
        .attr("cursor", "pointer")
        .attr("r", function(d) {
            if (d.depth > 6) return 6;
            return (12-d.depth)
        })

        .on({
            "mouseover": function() {
                var c = d3.select(this).classed("selected");
                d3.select(this).classed("selected", !c);
            },

            "mouseout": function() {
                var c = d3.select(this).classed("normal");
                d3.select(this).classed("normal", !c);
            },

            "click":  function(d) {
                var list = [];
                var list2 = [];
                list2.size = 0
                var tmp = d;

                list.push(tmp.id);
                list_of_children(d, list2);
                d.coc = list2.size;

                if (!d.parent) alert("Root" + d.depth)
                else {
                    while (tmp.parent != root) {
                        tmp = tmp.parent;
                        list.push(tmp.id);
                    }
                    list.push(tmp.parent.id);
                    if (d.children) alert(d.id + ", \nGłębokość: " + d.depth + "\nDo korzenia:" + list +
                    "\nSymulacje: " + list2 +
                    "\nLiczba symulacji:" + d.coc)
                    else {
                        var url = prefix + "/experiments/" + experiment_id + "/simulations/"+d.id;

                        alert(url);
                        var handler = function(data) {
                            $("<div id=simulation>").html(data);
                        }
                        sessionGetJSON(url, {}, handler);
                    }
                }
            }



        });



    node.append("text")
        .attr("dy", ".31em")
        .attr("text-anchor", function(d) { return d.x < 180 ? "start" : "end"; })
        .attr("transform", function(d) { return d.x < 180 ? "translate(8)" : "rotate(180)translate(-8)"; })
        .text(function(d) { if(!d.children) return d.id; }); // wyświ

    function list_of_children(d, list2) {
        var c = 0;
        for (ch in d.children)  {
            if(!d.children[ch].children) {
                list2.push(d.children[ch].id);
                list2.size++;
            }
            else {
//         list2.push(d.children[ch].id);
                list_of_children(d.children[ch], list2);
            }
        }
    }

    renderTo
        :
        $('#chart_' + i + " .chart")[0]


};