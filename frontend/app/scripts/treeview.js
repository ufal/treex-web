// nlp tree rendering based on d3js
(function(d3) {
  d3.layout.nlp = {};
  function noop() {}

  var defaultOptions = {
    nodeXSkip : 10,
    nodeYSkip : 5,
    marginX: 2,
    marginY: 2
  };

  d3.layout.nlp.constituency = function(opts) {
    var maxDepth;

    //TODO
    opts = defaultOptions;
    opts.nodeXSkip = 4;

    function layout(tree) {
      var nodes = tree.allNodes()
            .sort(function(a, b) { return d3.ascending(a.order, b.order); });

      maxDepth = d3.max(nodes, function(node) { return node.depth(); });

      return nodes;
    }

    layout.computeLayout = function(nodes) {
      var i = -1, ii = -1,
          n = nodes.length,
          widths = [],
          left = 0,
          levelWidths = [],
          heights = [],
          depth,
          node;

      // compute widths and heights

      while(++i < n) {
        node = nodes[i];
        depth = node.isLeaf() ? maxDepth : node.depth();

        if (!levelWidths[depth])
          levelWidths[depth] = 0;
        left += node.width / 2;

        if (i === 0) {
          widths[0] = left;
        } else {

          if (levelWidths[depth] >= left) {
            left = levelWidths[depth] + opts.nodeXSkip;
          } else {
            left += opts.nodeXSkip;
          }
          widths[i] = left;
          levelWidths[depth] = left + node.width;

          if (!node.isRoot() && node.children().length === 1) {
            left += 15;
          }
        }

        if (!heights[depth] || heights[depth] < node.height) {
          heights[depth] = node.height;
        }
      }

      heights.push(0);
      for(i = 0, ii = heights.length, depth = 0; i < ii; i++) {
        var swap = heights[i];
        heights[i] = depth;
        depth += swap;
      }

      i = -1;
      while(++i < n) {
        node = nodes[i];
        depth = node.isLeaf() ? maxDepth : node.depth();
        node.y = opts.marginY;

        node.y += heights[depth] + (opts.nodeYSkip + opts.marginY)*depth;
        node.x = opts.marginX + i*opts.marginX + widths[i];
      }
    };

    layout.nodes = layout;
    layout.links = d3_nlp_links;
    return layout;
  };

  d3.layout.nlp.tree = function(opts) {

    //TODO
    opts = defaultOptions;

    function layout(tree) { // expecting Treex.Tree here
      var nodes = tree.allNodes()
            .sort(function(a, b) { return d3.ascending(a.order, b.order); });
      return nodes;
    }

    layout.computeLayout = function(nodes) {
      var i = -1, ii = -1,
          n = nodes.length,
          widths = [],
          left = 0,
          levelWidths = [],
          heights = [],
          depth,
          node;

      // compute widths and heights

      while(++i < n) {
        node = nodes[i];
        depth = node.depth();

        if (!levelWidths[depth])
          levelWidths[depth] = 0;

        if (levelWidths[depth] >= left) {
          left = levelWidths[depth] + opts.nodeXSkip;
        } else {
          left += opts.nodeXSkip;
        }
        widths[i] = left;
        levelWidths[depth] = left + node.width;

        if (!heights[depth] || heights[depth] < node.height) {
          heights[depth] = node.height;
        }
      }

      heights.push(0);
      for(i = 0, ii = heights.length, depth = 0; i < ii; i++) {
        var swap = heights[i];
        heights[i] = depth;
        depth += swap;
      }

      i = -1;
      while(++i < n) {
        node = nodes[i];
        depth = node.depth();
        node.y = opts.marginY;

        node.y = heights[depth] + (opts.nodeYSkip + opts.marginY)*depth;
        node.x = opts.marginX + i*opts.marginX + widths[i];
      }
    };

    layout.nodes = layout;
    layout.links = d3_nlp_links;
    return layout;
  };

  // Returns an array source+target objects for the specified nodes.
  function d3_nlp_links(nodes) {
    return d3.merge(nodes.map(function(parent) {
      return (parent.children() || []).map(function(child) {
        return {source: parent, target: child};
      });
    }));
  }

  function d3_nlp_treeVisitAfter(node, callback) {
    function visit(node, previousSibling) {
      var children = node.children();
      if (children && (n = children.length)) {
        var child,
            previousChild = null,
            i = -1,
            n;
        while (++i < n) {
          child = children[i];
          visit(child, previousChild);
          previousChild = child;
        }
      }
      callback(node, previousSibling);
    }
    visit(node, null);
  }
})(d3);

(function(treex, d3) {

  function treeview(container) {
    this.$top = d3.select(container);
  }

  (function(twproto) {
    twproto.init = function(document) {
      var self = this,
          top = self.$top;
      self.$doc = document;
      self.bundle = 0;

      self.desc = null;
      self.svg = top
        .append('div').attr('class', 'treeview-gfx')
        .append('svg');
    };

    twproto.description = function(container) {
      this.desc = d3.select(container);
    };

    twproto.nextBundle = function() {
      var self = this;
      if (self.hasNextBundle()) {
        self.bundle += 1;
        self.drawBundle();
      }
    };

    twproto.hasNextBundle = function() {
      return (this.bundle+1) < this.$doc.bundles.length;
    };

    twproto.previousBundle = function() {
      var self = this;
      if (self.hasPreviousBundle()) {
        self.bundle -= 1;
        self.drawBundle();
      }
    };

    twproto.setBundle = function(bundle) {
      this.bundle = bundle;
      this.drawBundle();
    };

    twproto.hasPreviousBundle = function() {
      return this.bundle > 0;
    };

    twproto.drawBundle = function() {
      var self = this,
          bundle = self.$doc.bundles[self.bundle],
          desc = self.desc,
          svg = self.svg, w, h;

      if (desc) {
        displayDesc(desc, self.svg, bundle);
      }
      var trees = svg.selectAll('.tree')
            .data(bundle.allTrees(), function(d) { return d.language + '-' + d.layer; });
      trees.enter().append('g')
        .attr('class', 'tree');

      var lastTree;
      w = h = 0;
      trees.each(function(d, index) {
        var self = d3.select(this),
            style = treex.Stylesheet(d),
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
        });

        if (desc) {
          node.on('mouseover', function(d) { desc.selectAll('span.'+d.id).classed('highlight', true); })
            .on('mouseout', function(d) { desc.selectAll('span.'+d.id).classed('highlight', false); });
        }

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
        } else {
          w = bbox.x + bbox.width;
        }
        if (h < bbox.height) h = bbox.height;
        bbox.x = shift;
        self.attr('transform', "translate(" + bbox.x + "," + 10 + ")");
        lastTree = bbox;
      });
      trees.exit().remove();
      svg.attr('width', w)
        .attr('height', h+10);
    };

    function displayDesc(desc, top, bundle) {
      desc.selectAll('span').remove();
      var sentence = desc.selectAll('span')
            .data(bundle.desc);
      sentence.enter().append('span')
        .attr('class', function(d) { return d.slice(1).join(' '); })
        .each(function(d) {
          var self = d3.select(this),
              main = d[1];
          if (main == 'newline') self.append('br');
          else self.text(function(d) { return d[0]; });

          if (main == 'label' || main == 'newline' || main == 'space') {
            return;
          }
          self.classed('mouse-highlight', true);
          self.on('click', function(d) {
            var classes = d.slice(1),
                n = classes.length,
                i = -1,
                selector = '';
            if (n == 0) return;
            while (++i < n) {
              classes[i] = '#'+classes[i];
            }
            top.selectAll(classes.join(', '))
              .each(function(d) {
                var self = d3.select(this),
                    elem = d3.select(this.firstChild) || self,
                    bbox = this.firstChild ? this.firstChild.getBBox() : this.getBBox(),
                    halfWidth = bbox.width/2,
                    halfHeight = bbox.height/2,
                    r = Math.sqrt(halfWidth*halfWidth + halfHeight*halfHeight);
                self.append('circle')
                  .attr('cx', bbox.x + halfWidth)
                  .attr('cy', bbox.y + halfHeight)
                  .attr('r', r)
                  .attr('fill', 'none')
                  .attr('stroke', elem.style('fill') || 'orange')
                  .attr('stroke-width', 3)
                  .transition()
                  .duration(1000)
                  .attr('r', 4*r)
                  .remove();
              });
          });
        });
      sentence.exit().remove();
    }
  })(treeview.prototype);


  treex.TreeView = function(args) {
    return new treeview(args);
  };
})((Treex || (Treex = {})), d3);

// Stylesheet
(function(treex) {
  var window = this,
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
      coordPattern = /^(ADVS|APPS|CONFR|CONJ|CONTRA|CSQ|DISJ|GRAD|OPER|REAS)$/,
      r = 3.5,
      r2 = 7;

  treex.Stylesheet = function(tree) {
    return new stylesheet(tree);
  };

  function stylesheet(tree) {
    this.tree = tree;

    switch (tree.layer) {
    case 'p':
      this.styleNode = pnodeStyle;
      this.styleConnection = pnodeConnection;
      this.connect = manhattanConnect;
      break;
    case 't':
      this.styleNode = tnodeStyle;
      this.styleConnection = tnodeConnection;
      this.connect = directConnect;
      break;
    default:
      this.styleNode = anodeStyle;
      this.styleConnection = anodeConnection;
      this.connect = directConnect;
    }
  }

  stylesheet.prototype.isCoord = function(d) {
    if (this.layer !== 't') {
      return false;
    }
    return ((d != null ? d.data.functor : void 0) != null) && coordPattern.test(d.data.functor);
  };

  function anodeStyle(node) {
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

  function directConnect(link) {
    link.attr("x1", function(d) { return d.source.x+r+1; })
      .attr("y1", function(d) { return d.source.y+r+1; })
      .attr("x2", function(d) { return d.target.x+r+1; })
      .attr("y2", function(d) { return d.target.y+r+1; });
    return link;
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

  function pnodeStyle(node) {
    node.each(function(d) {
      var terminal = d.isLeaf(),
          self = d3.select(this),
          shape, ctype;
      if (terminal) {
        shape = circle(self)
          .attr('cx', 0)
          .attr('cy', 0);
        self.call(centeredLabel);
        self.select('text')
          .style('text-anchor', 'middle');
        ctype = d.attr('tag') === '-NONE-' ? 'trace' : d.attr('is_head') ? 'terminal_head' : 'terminal';
      } else {
        shape = pnode(self);
        ctype = d.attr('is_head') ? 'nonterminal_head' : 'nonterminal';
      }
      shape.attr('fill', colors[ctype]);
    });
    return node;
  }

  function pnodeConnection(link) {
    return link.append('path')
      .attr('stroke-width', 1)
      .attr('stroke', colors['edge'])
      .attr('fill', 'none')
      .attr('stroke-dasharray', function(d) { return d.target.isLeaf() ? '4,3' : 'none'; });
  }

  function manhattanConnect(link) {
    link.attr('d', function(d) {
      var from = d.source,
          to = d.target,
          fShift = from.isLeaf() ? r+1 : from.width/2,
          tShift = to.isLeaf() ? r+1 : to.width/2;

      return 'M'+ (from.x) +' '+ from.y + 'L'+ (to.x) +' '+ from.y +'L'+ (to.x) + ' ' + to.y;
    });
    return link;
  }

  function circle(node) {
    return node.append('circle')
      .style('stroke', colors['edge'])
      .style('stroke-width', 1)
      .attr('r', r)
      .attr('cx', r+1)
      .attr('cy', r+1);
  }

  function rectangle(node) {
    return node.append('rect')
      .attr('width', r2)
      .attr('height', r2)
      .attr('x', 1)
      .attr('y', 1)
      .style('stroke', colors['edge'])
      .style('stroke-width', 1);
  }

  function pnode(node) {
    return node.append('rect')
      .style('stroke', colors['edge'])
      .style('stroke-width', 1)
      .each(function(d) {
        var self = d3.select(this),
            parent = d3.select(this.parentNode),
            text = parent.append('text')
              .style('text-anchor', 'middle')
              .style('font-family', 'Arial')
              .style('font-size', '12px')
              .style('line-height', 'normal')
              .attr('stroke', 'none')
              .attr('font-size', '12px')
              .attr('font', '10px "Arial"')
              .call(buildLabel);
        var bbox = text.node().getBBox();
        text.attr('x', 0)
          .attr('y', bbox.height/2);
        self.attr('width', bbox.width+4)
          .attr('height', bbox.height+1)
          .attr('x', -bbox.width/2-1)
          .attr('y', -bbox.height/2+2);
        ;
      });
  }

  function standardLabel(node) {
    return node.append('rect')
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
              .style('line-height', 'normal')
              .call(buildLabel);
        var bbox = text.node().getBBox();
        self.attr('width', bbox.width+1)
          .attr('height', bbox.height+2);
      });
  }

  function centeredLabel(node) {
    return node.append('rect')
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
              .style('text-anchor', 'middle')
              .style('font-family', 'Arial')
              .style('font-size', '12px')
              .style('line-height', 'normal')
              .call(buildLabel);
        var bbox = text.node().getBBox();
        self.attr('width', bbox.width+2)
          .attr('height', bbox.height+2)
          .attr('x', -bbox.width/2+1);
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

})(Treex || (Treex = {}));