var vis, $tree, svg, desc;

var w = 1000,
    h = 400,
    radius = 8,
    cursorRadius = radius * 3,
    padding = 20;
$tree = d3.select('#tree');
vis = $tree.append('div').attr('class', 'controls');
desc = $tree.append('p').attr('class', 'desc');
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
            console.log(bundle);
            desc.selectAll('span').remove();
            var sentence = desc.selectAll('span')
                    .data(bundle.desc);
            sentence.enter().append('span')
                .each(function(d) {
                    var self = d3.select(this);
                    if (d[1] == 'newline') self.append('br');
                    else self.text(function(d) { return d[0]; });
                })
                .attr('class', function(d) { return d.slice(1).join(' '); })
                .on('click', function(d) {
                    var self = d3.select(this),
                        classes = self.attr('class').split(' '),
                        n = classes.length,
                        i = -1,
                        selector = '';
                    if (n == 0) return;
                    while (++i < n) {
                        classes[i] = '#'+classes[i];
                    }
                    svg.selectAll(classes.join(', '))
                        .each(function(d) {
                            var self = d3.select(this),
                                bbox = this.firstChild.getBBox(),
                                halfWidth = bbox.width/2,
                                halfHeight = bbox.height/2,
                                r = Math.sqrt(halfWidth*halfWidth + halfHeight*halfHeight);
                            console.log(bbox);
                            self.append('circle')
                                .attr('cx', bbox.x + halfWidth)
                                .attr('cy', bbox.y + halfHeight)
                                .attr('r', r)
                                .attr('fill', 'none')
                                .attr('stroke', 'orange')
                                .attr('stroke-width', 3)
                                .transition()
                                .duration(1000)
                                .attr('r', 3*r)
                                .remove();
                        });
                });
            sentence.exit().remove();

            var trees = svg.selectAll('.tree')
                    .data(bundle.allTrees(), function(d) { return d.language + '-' + d.layer; });
            trees.enter().append('g')
                    .attr('class', 'tree');

            var lastTree;
            w = h = 0;
            trees.each(function(d, index) {
                var self = d3.select(this),
                    style = Treex.Stylesheet(d),
                    tree = d.layer == 'p' ? d3.layout.nlp.constituency() : d3.layout.nlp.tree(),
                    nodes = tree.nodes(d),
                    links = tree.links(nodes);
                var r = 3.5;

                !self.select('g.links').empty() || self.append('g').attr('class', 'links');
                !self.select('g.nodes').empty() || self.append('g').attr('class', 'nodes');

                var link = self.select('g.links').selectAll('.link')
                        .data(links, function(d) { return d.source.uid + '|' + d.target.uid; });
                style.styleConnection(link.enter())
                    .attr('class', 'link')
                    .order();

                var node = self.select('g.nodes').selectAll('.node')
                        .data(nodes, function(d) { return d.uid; });
                style.styleNode(node.enter().append('g')
                                .attr('class', 'node')
                                .attr('id', function(d) { return d.id; }));

                node.each(function(d) {
                    var bbox = this.getBBox();
                    d.figure = this;
                    d.width = bbox.width;
                    d.height = bbox.height;
                })
                    .on('mouseover', function(d) {
                        desc.selectAll('span.'+d.id).classed('highlite', true);
                    })
                    .on('mouseout', function(d) {
                        desc.selectAll('span.'+d.id).classed('highlite', false);
                    });

                tree.computeLayout(nodes);

                style.connect(link);
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
                self.attr('transform', "translate(" + bbox.x + "," + 10 + ")");
                lastTree = bbox;
            });
            trees.exit().remove();
            svg.attr('width', w)
               .attr('height', h);
        }
    });
}

fetch();
