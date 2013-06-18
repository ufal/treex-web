var vis, $tree, svg, sentence;

var w = 1000,
    h = 400,
    radius = 8,
    cursorRadius = radius * 3,
    padding = 20;
$tree = d3.select('#tree');
vis = $tree.append('div').attr('class', 'controls');
sentence = $tree.append('div').attr('class', 'sentence');
svg = $tree.append('svg')
    .attr('width', w)
    .attr('height', h)
    .style('padding', padding + 'px');

//svg = d3.select("#tree svg");

function fetch() {
    d3.json('print2.json', function(json) {

        var data = Treex.Document.fromJSON(json.print);
        var controls = vis.selectAll('button')
            .data(data.bundles);
        controls.enter().append('button')
            .on('click', function(d) { drawBundle(d); })
            .text(function(d, i) { return i; });
        controls.exit().remove();

        function drawBundle(bundle) {
            var sentences = sentence.selectAll('p')
                    .data(bundle.allZones(), function(d) { return d.sentence; });
            sentences.enter().append('p')
                .text(function(d) { return '['+ d.label +'] ' + d.sentence; });
            sentences.exit().remove();

            var trees = svg.selectAll('.tree')
                    .data(bundle.allTrees(), function(d) { return d.layer; });
            trees.enter().append('g')
                    .attr('class', 'tree');

            var lastTree;
            w = h = 0;
            trees.each(function(d, index) {
                var self = d3.select(this),
                    style = Treex.Stylesheet(d),
                    tree = d3.layout.nlp.tree(),
                    nodes = tree.nodes(d),
                    links = tree.links(nodes);
                var r = 3.5;

                !self.select('g.links').empty() || self.append('g').attr('class', 'links');
                !self.select('g.nodes').empty() || self.append('g').attr('class', 'nodes');

                var link = self.select('g.links').selectAll('.link')
                        .data(links);
                style.styleConnection(link.enter())
                    .attr('class', 'link')
                    .order();

                var node = self.select('g.nodes').selectAll('.node')
                        .data(nodes, function(d) { return d.uid; });
                style.styleNode(node.enter().append('g')
                                .attr('class', 'node'));

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
                link.exit().remove();

                //node.attr('transform', function(d) { return "translate(" + d.x + "," +  d.y + ")"; });
                node.attr('transform', function(d) { return "translate(" + d.x + "," +  d.y + ")"; });
                node.exit().remove();

                var bbox = this.getBBox(),
                    shift = 0;

                if (lastTree) {
                    shift = lastTree.x + lastTree.width + 10;
                    w = shift + bbox.width;
                }
                if (h < bbox.height) h = bbox.height;
                bbox.x = shift;
                self.attr('transform', "translate(" + bbox.x + "," + bbox.y + ")");
                lastTree = bbox;
            });
            trees.exit().remove();
            svg.attr('width', w)
               .attr('height', h);
        }
    });
}

fetch();
