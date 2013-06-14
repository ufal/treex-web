var vis, svg;

var w = 1000,
    h = 400,
    radius = 8,
    cursorRadius = radius * 3,
    padding = 20;

var tree = d3.layout.nlp.tree();
        // .children(function(d) {
        //     var nodes = d.node.children(),
        //         n = nodes.length,
        //         i = -1,
        //         children = [];
        //     while(++i < n) {
        //         children.push({ node: nodes[i] });
        //     }
        //     return children;
        // })
        // .sort(function(a, b) { return d3.ascending(a.node.order, b.node.order); })
        // .size([w-10, h-10]);

//.separation(function(a, b) { return (a.parent == b.parent ? 1 : 2) / a.depth; });

vis = d3.select("#tree").append("svg")
    .attr("width", w)
    .attr("height", h)
    .style("padding", padding + "px");

svg = d3.select("#tree svg");

function drawTree() {
    d3.json('print.json', function(json) {
        console.log(json);

        var data = Treex.Document.fromJSON(json.print);

        var r = 3.5;
        var nodes = tree.nodes(data.bundles[0].zones['en'].trees['en-a']);
        var links = tree.links(nodes);

        console.log(links);

        var link = svg.selectAll('.link')
            .data(links)
            .enter().append('line')
            .attr('class', 'link')
            .style('stroke-width', 2)
            .style('stroke', d3.rgb(0,0,0));

        var node = svg.selectAll('.node')
                .data(nodes)
                .enter().append('g')
                .attr('class', 'node');

        node.append('circle')
            .style('fill', 'lightblue')
            .style('stroke', d3.rgb(0,0,0))
            .style('stroke-width', 1)
            .attr('r', r)
            .attr('cx', r+1)
            .attr('cy', r+1);
        var label = node.append('rect')
                .attr('x', 0)
                .attr('y', 9)
                .style('fill-opacity', 0.9)
                .attr('fill', d3.rgb(255,255,255))
                .each(function(d) {
                    var self = d3.select(this),
                        parent = d3.select(this.parentNode),
                        text = parent.append('text')
                            .attr('dx', 1)
                            .attr('dy', 22)
                            .style('text-anchor', 'start')
                            .style('font-size', '12px')
                            .call(makeLabel);
                    var bbox = text.node().getBBox();
                    self.attr('width', bbox.width+1)
                        .attr('height', bbox.height+2);
                });

        function makeLabel(selection) {
            selection.each(function(d) {
                if (!d.labels) return;
                var self = d3.select(this),
                    labels = d.labels;
                for (var i = 0, ii = labels.length; i < ii; i++) {
                    var tspan, label = labels[i],
                        n = label.match(/#\{[\w#]+\}/g),
                        parts = label.split(/#\{[\w#]+\}/);
                    !parts[0] && parts.length > 1 && parts.shift(); // first element might be empty
                    for (var j = 0, jj = parts.length; j < jj; j++) {
                        var fill = null;
                        if (n && j < n.length) fill = n[j].slice(2, -1); // kill brackets
                        tspan = self.append('tspan');
                        i && j == 0 && tspan.attr('dy', 12 * 1.2);
                        j==0 && tspan.attr('x', 1);
                        fill && tspan.attr('fill', fill);
                        tspan.text(parts[j]);
                    }
                }
            });
        }

        node.each(function(d) {
            var bbox = this.getBBox();
            d.figure = this;
            d.width = bbox.width;
            d.height = bbox.height;
        });

        tree.computeLayout(nodes);

        link.attr("x1", function(d) { return d.source.x+r+1; })
            .attr("y1", function(d) { return d.source.y+r+1; })
            .attr("x2", function(d) { return d.target.x+r+1; })
            .attr("y2", function(d) { return d.target.y+r+1; });
        node.attr('transform', function(d) { return "translate(" + d.x + "," +  d.y + ")"; });
    });
}

drawTree();
