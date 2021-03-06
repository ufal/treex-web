
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
        var grid,
            maxDepth;

        //TODO
        opts = defaultOptions;
        opts.nodeXSkip = 4;

        function layout(tree) {
            var nodes = tree.allNodes()
                    .sort(function(a, b) { return d3.ascending(a.order, b.order); });

            maxDepth = d3.max(nodes, function(node) { return node.depth(); });

            function populateGrid() {
                var i = -1,
                    n = nodes.length,
                    depth,
                    node;
                grid = {};

                while(++i < n) {
                    node = nodes[i];
                    depth = node.isLeaf() ? maxDepth : node.depth();
                    if (!grid[depth]) {
                        grid[depth] = {};
                    }
                    grid[depth][node.order] = node;
                }
            }

            populateGrid();
            return nodes;
        }

        layout.computeLayout = function(nodes) {
            var i = -1, j = -1,
                n = nodes.length,
                widths = [],
                left = 0,
                levelWidth = 0,
                heights = {},
                depth,
                node;

            // compute widths and heights

            while(++i < n) {
                node = nodes[i];
                depth = node.isLeaf() ? maxDepth : node.depth();
                j = i;
                levelWidth = 0;

                left += node.width / 2;

                if (i === 0) {
                    widths[0] = left;
                } else {
                    while (--j > 0) {
                        var nbr = grid[depth][j];
                        if (!nbr) continue;
                        levelWidth = widths[j] + nbr.width;
                        break;
                    }

                    if (levelWidth >= left) {
                        left = levelWidth + opts.nodeXSkip;
                    } else {
                        left += opts.nodeXSkip;
                    }
                    widths[i] = left;
                    if (!node.isRoot() && node.children().length === 1) {
                        left += 15;
                    }
                }

                if (!heights[depth] || heights[depth] < node.height) {
                    heights[depth] = node.height;
                }
            }

            i = -1;
            while(++i < n) {
                node = nodes[i];
                depth = node.isLeaf() ? maxDepth : node.depth();
                node.y = opts.marginY;

                while(--depth >= 0) {
                    node.y += heights[depth] + opts.nodeYSkip + opts.marginY;
                }
                node.x = opts.marginX + i*opts.marginX + widths[i];
            }
        };

        layout.nodes = layout;
        layout.links = d3_nlp_links;
        return layout;
    };

    d3.layout.nlp.tree = function(opts) {
        var grid;

        //TODO
        opts = defaultOptions;

        function layout(tree) { // expecting Treex.Tree here
            var nodes = tree.allNodes()
                    .sort(function(a, b) { return d3.ascending(a.order, b.order); });
            function populateGrid() {
                var i = -1,
                    n = nodes.length,
                    depth,
                    node;
                grid = {};

                while(++i < n) {
                    node = nodes[i];
                    depth = node.depth();
                    if (!grid[depth]) {
                        grid[depth] = {};
                    }
                    grid[depth][node.order] = node;
                }
            }

            populateGrid();
            return nodes;
        }

        layout.computeLayout = function(nodes) {
            var i = -1, j = -1,
                n = nodes.length,
                widths = [],
                left = 0,
                levelWidth = 0,
                heights = {},
                depth,
                node;

            // compute widths and heights

            while(++i < n) {
                node = nodes[i];
                depth = node.depth();
                j = i;
                levelWidth = 0;
                while (--j > 0) {
                    var nbr = grid[depth][j];
                    if (!nbr) continue;
                    levelWidth = widths[j] + nbr.width;
                    break;
                }

                if (levelWidth >= left) {
                    left = levelWidth + opts.nodeXSkip;
                } else {
                    left += opts.nodeXSkip;
                }
                widths[i] = left;

                if (!heights[depth] || heights[depth] < node.height) {
                    heights[depth] = node.height;
                }
            }

            i = -1;
            while(++i < n) {
                node = nodes[i];
                depth = node.depth();
                node.y = opts.marginY;

                while(--depth >= 0) {
                    node.y += heights[depth] + opts.nodeYSkip + opts.marginY;
                }
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