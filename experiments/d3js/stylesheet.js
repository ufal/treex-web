
(function() {
    var window = this,
        treex = window['Treex'] || (window['Treex'] = {}),
        colors = {
            'edge': '#555555',
            'coord': '#bbbbbb',
            'error': '#ff0000',
            'anode': '#ff6666',
            'anode_coord': '#ff6666',
            'nnode': '#ffff00',
            'tnode': '#4488ff',
            'tnode_coord': '#ccddff',
            'terminal': '#ffff66',
            'terminal_head': '#90ee90',
            'nonterminal_head': '#90ee90',
            'nonterminal': '#ffffe0',
            'trace': '#aaaaaa',
            'current': '#ff0000',
            'coref_gram': '#c05633',
            'coref_text': '#4c509f',
            'compl': '#629f52',
            'alignment': '#bebebe',
            'coindex': '#ffa500',
            'lex': '#006400',
            'aux': '#ff8c00',
            'parenthesis': '#809080',
            'afun': '#00008b',
            'member': '#0000ff',
            'sentmod': '#006400',
            'subfunctor': '#a02818',
            'nodetype': '#00008b',
            'sempos': '#8b008b',
            'phrase': '#00008b',
            'formeme': '#b000b0',
            'tag': '#004048',
            'tag_feat': '#7098A0',
            'clause0': '#ff00ff',
            'clause1': '#ffa500',
            'clause2': '#0000ff',
            'clause3': '#3cb371',
            'clause4': '#ff0000',
            'clause5': '#9932cc',
            'clause6': '#00008b',
            'clause7': '#006400',
            'clause8': '#8b0000',
            'clause9': '#008b8b'
        },
        coordPattern = /^(ADVS|APPS|CONFR|CONJ|CONTRA|CSQ|DISJ|GRAD|OPER|REAS)$/;

    treex['Stylesheet'] = function(tree) {
        return new stylesheet(tree);
    };

    function stylesheet(tree) {
        this.tree = tree;

        switch (tree.layer) {
        case 'p':
            this.styleNode = pnodeStyle;
            this.styleConnection = pnodeConnection;
            break;
        case 't':
            this.styleNode = tnodeStyle;
            this.styleConnection = tnodeConnection;
            break;
        default:
            this.styleNode = anodeStyle;
            this.styleConnection = anodeConnection;
        }
    }

    stylesheet.prototype.isCoord = function(d) {
        if (this.layer !== 't') {
            return false;
        }
        return ((d != null ? d.data.functor : void 0) != null) && coordPattern.test(d.data.functor);
    };

    function anodeStyle(node) {
        var r = 3.5;
        circle(node)
            .style('fill', colors['anode']);
        node.call(standardLabel);
        return node;
    }

    function anodeConnection(link) {
        return link.append('line')
            .style('stroke-width', 2)
            .style('stroke', colors['edge']);
    }

    function tnodeStyle(node) {
        var self = this;
        node.each(function(d) {
            var n = d3.select(this),
                shape = d.attr('is_generated') ? rectangle(n) : circle(n);
            shape.attr('fill', function(d) {
                return (!d.isRoot() && self.isCoord(d)) ? colors['tnode_coord'] : colors['tnode'];
            });
        });
        node.call(standardLabel);
        return node;
    }

    function tnodeConnection(link) {
        var self = this;
        link = link.append('line')
            .each(function(d) {
                var source = d.source,
                    target = d.target,
                    link = d3.select(this),
                    color = colors['edge'],
                    width = 2,
                    dash = null;
                if (target.attr('is_member')) {
                    if (!target.isRoot() && self.isCoord(source)) {
                        width = 1;
                        color = colors['coord'];
                    } else {
                        color = colors['error'];
                    }
                } else if (!target.isRoot() && self.isCoord(source)) {
                    color = colors['coord_mod'];
                } else if (self.isCoord(target)) {
                    color = colors['coord'];
                    width = 1;
                }
                var functor = target.attr('functor') != null ? target.attr('functor')[0]['#value'] : '';
                if (functor.match(/^(PAR|PARTL|VOCAT|RHEM|CM|FPHR|PREC)$/) || (!target.isRoot() && source.isRoot())) {
                    width = 1;
                    dash = '1, 2';
                    color = colors['edge'];
                }
                link.style('stroke-width', width)
                    .style('stroke', color);
                if (dash) link.style('stroke-dasharray', dash);

            });
        return link;
    }

    function pnodeStyle(node) {}
    function pnodeConnection(link) {}

    function circle(node) {
        var r = 3.5;
        return node.append('circle')
            .style('stroke', colors['edge'])
            .style('stroke-width', 1)
            .attr('r', r)
            .attr('cx', r+1)
            .attr('cy', r+1);
    }

    function rectangle(node) {
        return node.append('rect')
            .attr('width', 7)
            .attr('height', 7)
            .attr('x', 1)
            .attr('y', 1)
            .style('stroke', colors['edge'])
            .style('stroke-width', 1);
    }

    function standardLabel(node) {
        node.append('rect')
            .attr('x', 0)
            .attr('y', 9)
            .style('fill-opacity', 0.9)
            .attr('fill', 'white')
            .each(function(d) {
                var self = d3.select(this),
                    parent = d3.select(this.parentNode),
                    text = parent.append('text')
                        .attr('dx', 1)
                        .attr('dy', 22)
                        .style('text-anchor', 'start')
                        .style('font-family', 'Arial')
                        .style('font-size', '12px')
                        .call(buildLabel);
                var bbox = text.node().getBBox();
                self.attr('width', bbox.width+1)
                    .attr('height', bbox.height+2);
            });
    }

    function buildLabel(selection) {
        // TODO: selection.selectAll('tspan').data(function(d) { return d.labels; })
        selection.each(function(d) {
            if (!d.labels) return;
            var self = d3.select(this),
                labels = d.labels;
            for (var i = 0, ii = labels.length; i < ii; i++) {
                var tspan, label = labels[i]||'',
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

}).call(window);