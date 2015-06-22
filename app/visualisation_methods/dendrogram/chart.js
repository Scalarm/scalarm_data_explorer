dendrogram_main = function(i, param1, data) {
    alert(data);
    var root3 = {"id":"4","children":[{"id":"3","children":[{"id":"1","children":[{"id":"-20"},{"id":"-25"}]},{"id":"-21"}]},{"id":"2","children":[{"id":"-28"},{"id":"-22"}]}]}

    var root = {"id":"105","children":[{"id":"84","children":[{"id":"18"},{"id":"62"}]},{"id":"104","children":[{"id":"100","children":[{"id":"85","children":[{"id":"72","children":[{"id":"38","children":[{"id":"27"},{"id":"35"}]},{"id":"51"}]},{"id":"73","children":[{"id":"84"},{"id":"90"}]}]},{"id":"94","children":[{"id":"81","children":[{"id":"76","children":[{"id":"66","children":[{"id":"37","children":[{"id":"34"},{"id":"69"}]},{"id":"83"}]},{"id":"82"}]},{"id":"45"}]},{"id":"89","children":[{"id":"75","children":[{"id":"56","children":[{"id":"20"},{"id":"55"}]},{"id":"99"}]},{"id":"57"}]}]}]},{"id":"102","children":[{"id":"96","children":[{"id":"91","children":[{"id":"50","children":[{"id":"30","children":[{"id":"12"},{"id":"31"}]},{"id":"39"}]},{"id":"19"}]},{"id":"92","children":[{"id":"78","children":[{"id":"33","children":[{"id":"3"},{"id":"64"}]},{"id":"103"}]},{"id":"87"}]}]},{"id":"97","children":[{"id":"83","children":[{"id":"71","children":[{"id":"61","children":[{"id":"47"},{"id":"74"}]},{"id":"49"}]},{"id":"42"}]},{"id":"90","children":[{"id":"64","children":[{"id":"28","children":[{"id":"5"},{"id":"22"}]},{"id":"81"}]},{"id":"82","children":[{"id":"49","children":[{"id":"23"},{"id":"78"}]},{"id":"69","children":[{"id":"41","children":[{"id":"8"},{"id":"77"}]},{"id":"101"}]}]}]}]}]}]}]}

    var si = 30;


    var radius = si*15;
    var margin = 100;
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
                var gg = "link";
                alert(gg) }
        })
        .style("stroke", function(d) { return color(d.source.depth); });



    var node = svg.selectAll(".node")
        .data(nodes)
        .enter().append("g")
        .attr("class","node")
        .attr("transform", function(d) { return "rotate(" + (d.x - 90) + ")translate(" + d.y + ")"; });

    node.append("circle")
        .attr("r", function(d) {
            var list2 = []; list2.size = 0
            list_of_children(d,list2);
            if (list2.size+4 < 12) d.coc = (list2.size+4);
            else d.coc = 12;
            return d.coc;})


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
                var list2 = []; list2.size = 0
                var tmp = d;

                list.push(tmp.id);
                list_of_children(d,list2);
                d.coc = list2.size;
                while (tmp.parent != root) {
                    tmp = tmp.parent;
                    list.push(tmp.id);
                }
                list.push(tmp.parent.id);



                if(d.children) alert(d.id + "\nDo korzenia:" + list +
                "\nSymulacje: " + list2 +
                "\nLiczba symulacji:" + d.coc)}
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