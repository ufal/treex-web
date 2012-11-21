/* global Raphael */

/*
 * Michal Sedlak 2012
 *
 * Drawing extension for Treex Core
 *
 */

(function(treex) {

    var _ = treex._;

    _.mixin({
        // the middle function simply forces keys to ints
        topkey : _.compose(_.max, function(arr) { for(var i=0; i < arr.length; i++) arr[i] = +arr[i]; return arr; }, _.keys)
    });

    // new items in the namespace
    var Renderer = {}, Style = {}, Layout = {};

    // rendered using Raphael lib
    Renderer.Raphael = function(canvas, width, height) {
        this.width = width || 400;
        this.height = height || 400; // this is minimum

        this.r = Raphael(canvas, this.width, this.height);
    };

    treex.Renderer = function(canvas, width, height) { return new Renderer.Raphael(canvas, width, height); };

    Renderer.Raphael.renderNode = function(r, style, layout) {
        var node = style.node;
        var color = style.color || Raphael.getColor();
        var bg_rect = r.rect(0, 3.5, 0, 0).attr({ fill: '#FFF', 'stroke-width': "0", stroke: '#FFF', opacity: 0.9 });
        var circle = r.circle(0, 0, 3.5).attr({ fill: color, stroke: '#000', 'stroke-width': 1, title: style.title });
        var label = r.text(-5, 11, style.label).attr({'text-anchor' : 'start'});
        var box = label.getBBox();
        bg_rect.attr(box);
        /* set DOM node ID */
        circle.node.id = node.id;
        var shape = r.set().
            push(circle).
            push(label).
            push(bg_rect);
        return shape;
    };

    Renderer.Raphael.prototype = {

        dump: function() {
            console.log(this);
        },

        /*
         * Tree placement layout
         */
        calcTreesPlacement: function() {
            if (this.trees.length <= 1)
                return;

            var counter = 0,
            offsetX = 0,
            offsetY = 0;
            for (var i in this.styles) {
                var layout = this.styles[i].layout;
                layout.offsetX = offsetX;
                layout.offsetY = 0; // offsetY; ignore for now

                offsetX += layout.width;
                offsetY += layout.height;
            }
        },

        adjustCanvasSize: function() {
            var width = 0, height = 0;
            _.each(this.styles, function(style) {
                width += style.layout.width;
                height = Math.max(height, style.layout.height);
            });

            this.width = width;
            this.height = height;
            this.r.setSize(width, height);
            this.drawGrid();
        },

        drawGrid: function() {
            if (this.grid)
                this.grid.show();

            // this.grid = this.r.rect(0, 0, this.width, this.height).attr({fill: "url('static/images/grid.png')"}).toBack();
        },

        // first draw
        render: function(trees) {
            var self = this;
            this.trees = [];
            // styles are actually wrapped trees
            this.styles = _.map(trees, function(tree) {
                self.trees.push(tree);
                var style = treex.Style(tree); // initialize style for each tree
                style.layout.initialize();
                // initialize node height and width
                _.each(style.nodes, function(node) {
                    node = node.node;
                    var nodeLayout = style.layout.getNodeLayout(node);
                    var bbox = self.nodeBBox(node, style);
                    nodeLayout.width = bbox.width;
                    nodeLayout.height = bbox.height;
                    nodeLayout.topX = bbox.x;
                    nodeLayout.topY = bbox.y;
                    nodeLayout.bottomX = bbox.x2;
                    nodeLayout.bottomY = bbox.y2;
                });
                style.layout.calculate();
                return style;
            });
            this.calcTreesPlacement();
            this.adjustCanvasSize();

            this.redraw();
        },

        redraw: function() {
            var self = this;
            _.each(this.trees, function(tree, index){
                var style = self.styles[index];
                // use styled nodes
                // each node is wrapped, so are the edges
                _.each(style.nodes, function(n){
                    self.drawNode(n, style);
                });
                _.each(style.edges, function(e){
                    self.drawEdge(e, style);
                });
            });
        },

        nodeShape: function(node, style) {
            var nodeStyle = style.getNodeStyle(node);
            if (!nodeStyle.shape) {
                if (!nodeStyle.render)
                    nodeStyle.render = Renderer.Raphael.renderNode;
                var nodeLayout = style.layout.getNodeLayout(node);
                nodeStyle.shape = nodeStyle.render(this.r, nodeStyle, nodeLayout);
            }

            return nodeStyle.shape;
        },

        nodeBBox: function(node, style) {
            var shape = this.nodeShape(node, style);

            return shape.getBBox(true);
        },

        // node passed is a wrapped node object from Style
        // Access underlying node as node.node
        drawNode: function(node, style) {
            if(node.shape) {
                var rnode = node.node;
                var oBBox = this.nodeBBox(rnode, style);
                var point = style.layout.translate(rnode);
                var opoint = { x: oBBox.x, y: oBBox.y };
                node.shape.transform(['t'+Math.round(point[0] - opoint.x), Math.round(point[1] - opoint.y)].join(','));
            }
        },

        drawEdge: function(edge, style) {
            if(edge.source.hidden || edge.target.hidden) {
                edge.connection && edge.connection.fg.hide();
                edge.connection.bg && edge.connection.bg.hide();
                return;
            }
            /* if edge already has been drawn, only refresh the edge */
            if(!edge.connection) {
                // get shapes
                var sourceNode = style.getNodeStyle(edge.source);
                var targetNode = style.getNodeStyle(edge.target);
                edge.connection = this.r.connection(sourceNode.shape, targetNode.shape, style);
                return;
            }
            //FIXME showing doesn't work well
            edge.connection.fg.show();
            edge.connection.bg && edge.connection.bg.show();
            edge.connection.draw();
        }
    };

    Style = function(tree) {
        this.tree = tree;
        this.nodes = { };
        this.edges = [];

        this.selectStyle(tree);

        this.layout = new this.style.layout(tree);

        var self = this;
        _.each(tree.allNodes(), function(node) {
            var style = node.is_root() ?
                self.style.root : self.style.node;

            style = self.applyStyles(node, style);
            style.node = node;
            //style.layout = this.layout; // for easier access pass reference of the layout
            self.nodes[node.uid] = style;
        });

        function add_edges(node) {
            _.each(node.children(), function(child) {
                var edge = {
                    source : node,
                    target : child
                };
                var style = self.applyStyles(edge, self.style.edge);
                console.log(edge);
                _.extend(edge, style);
                self.edges.push(edge);
                if (child.firstson)
                    add_edges(child);
            });
        }
        add_edges(tree.root);
    };

    treex.Style = function(tree) { return new Style(tree); };

    Style.styles = { };

    Style.prototype = {
        selectStyle: function(tree) {
            // choose style
            this.style = { };
            if (Style.styles[tree.layer]) {
                this.style = Style.styles[tree.layer];
            }

            _.defaults(this.style, Style.default);
            console.log(this);
        },

        applyStyles: function(obj, style) {
            var s = { };
            _.each(style, function(val, key) {
                s[key] = _.isFunction(val) ? val(obj) : val;
            });

            return s;
        },
        getNodeStyle: function(node) {
            if (this.nodes[node.uid])
                return this.nodes[node.uid];
            return { };
        },

        getEdgeStyle: function(source, target) {
            return  _.find(this.edges, function(edge) {
                return edge.source.uid == source.uid &&
                    edge.target.uid == target.uid;
            });
        }
    };


    treex.Layout = Layout;

    var NodeLayout = function(node) {
        this.node = node;

        this.layoutPosX =
            this.layoutPosY =
            this.realPosX =
            this.realPosY =
            this.width =
            this.height = 0;
    };

    Layout.Tred = function(tree) {
        this.tree = tree; // the tree
        this.radiusX = 5; // node radius
        this.radiusY = 34;
        this.diameter = 2*this.radiusX;
        // this.margin = 5; // node margin

        this.nodes = { }; // hash of all nodes
        this.universe = { }; // sparse matrix of the layout, actualy now represented as hash

        this.width = 400;
        this.height = 400;

        this.layoutMaxX =
            this.layoutMaxY = 0;

        this.offsetX = 0;
        this.offsetY = 0;
    };

    Layout.Tred.prototype = {
        initialize: function() {
            // sort nodes
            this.order = _.sortBy(this.tree.allNodes(), function(node){ return node.order; });
            this.layoutPrepare();
        },

        calculate: function() {
            this.calcNodesPosition();
            this.calcBounds();
        },

        layoutPrepare: function() {
            var i = 0;
            var self = this;
            this.nodes = { }; // clear nodes first
            _.each(this.order, function(n) {
                var node = new NodeLayout(n);
                self.setNode(i++, n.level(), node);
            });
        },

        calcBounds: function() {
            var maxx = 0, maxy = 0;
            var self = this;
            this.width = this.height = 0;

            _.each(this.nodes, function(node){
                var x = node.layoutPosX;
                var y = node.layoutPosY;

                if(x > maxx) maxx = x;
                if(y > maxy) maxy = y;

                var width = node.realPosX + node.bottomX;
                if (width > self.width) self.width = width;

                var height = node.realPosY + node.bottomY;
                if (height > self.height) self.height = height;
            });

            this.layoutMaxX = maxx;
            this.layoutMaxY = maxy;

            this.width += this.radiusX;
            this.height += this.radiusX;
        },

        calcNodesPosition: function() {
            var self = this;
            // X pos
            var left = this.radiusX;
            _.each(this.order, function(node) {
                var layout = self.getNodeLayout(node);
                if (!layout) return;
                var leftWidth = 0;
                for (var i=layout.layoutPosX-1; i >= 0; i--) {
                    var n = self.getNode(i, layout.layoutPosY);
                    if (!n) continue;
                    leftWidth = n.realPosX + n.bottomX;
                    break;
                }
                if (leftWidth >= left-Math.abs(layout.topX)) {
                    layout.realPosX = leftWidth + Math.abs(layout.topX) + self.radiusX;
                    left = layout.realPosX + Math.abs(layout.topX);
                } else {
                    layout.realPosX = left + self.radiusX;
                    left += self.radiusX*2;
                }
            });

            _.each(this.nodes, function(node) {
                node.realPosY = (node.layoutPosY)*2*self.radiusY + node.height/2 + self.radiusX;
            });
        },

        translate: function(node) {
            if(!this.nodes[node.uid]) return [20, 20];
            node = this.nodes[node.uid];
            return [
                node.realPosX + this.offsetX,
                node.realPosY + this.offsetY
            ];
        },

        getNode: function(x, y) {
            if (x < 0 || y < 0  // indexes can't be negative
                || !this.universe[y] || !this.universe[y][x]) {
                return null;
            }
            // NOTE: do not refactor to return ?:
            return this.universe[y][x];
        },

        setNode: function(x, y, node) {
            if (!this.universe[y])
                this.universe[y] = { };
            this.universe[y][x] = node;

            node.layoutPosX = x;
            node.layoutPosY = y;

            // also index the node
            this.nodes[node.node.uid] = node;

            if (x > this.layoutMaxX) this.layoutMaxX = x;
            if (y > this.layoutMaxY) this.layoutMaxY = y;
        },

        removeNode: function(node) {
            var layout = this.nodes[node.uid];
            delete this.nodes[node.uid];
            if (layout) {
                // remove layout from the universe
                delete this.universe[layout.layoutPosY][layout.layoutPosX];
                if (_.isEmpty(this.universe[layout.layoutPosY]))
                    delete this.universe[layout.layoutPosY];

                if (!_.isEmpty(this.universe)) {
                    var maxLayout = this.maxLayoutX();
                    this.layoutMaxX = maxLayout.layoutPosX || 0;
                    maxLayout = this.maxLayoutY();
                    this.layoutMaxY = maxLayout.layoutPosY || 0;
                } else { // we've deleted the last item from the universe
                    this.layoutMaxX = this.layoutMaxY = 0;
                }
            }
        },

        // returns bottom right corner item of the matrix
        maxLayoutX: function() {
            if (_.isEmpty(this.universe))
                return null;
            var row = _.max(this.universe, _.topkey);
            return row[_.topkey(row)];
        },

        maxLayoutY: function() {
            if (_.isEmpty(this.universe))
                return null;
            var row = this.universe[_.topkey(this.universe)];
            return row[_.topkey(row)];
        },

        getNodeLayout: function(node) {
            if (this.nodes[node.uid])
                return this.nodes[node.uid];
            return null;
        }
    };

    // default options
    var opts = {
        renderNode: Renderer.Raphael.renderNode,
        renderer: treex.Raphael
    };
    _.extend(treex.opts, opts);

    Style.default = {
        node: { color : '#C80000', hidden : false, title : '', label : function(node) { return node.id; } },
        root: { color : '#000', hidden : false, title : '', label : function(root) { return root.id; } },
        edge: { color : '#000', hidden : false },
        layout : Layout.Tred
    };

})(this.Treex); // possibility of using different version
