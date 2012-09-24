/*
 * Michal Sedlak 2012
 *
 * Drawing extension for Treex Core
 * 
 */

(function(treex) {
    
    var _ = treex._;
    
    // new items in the namespace
    var Renderer = {}, Style = {}, Layout = {};
    
    // rendered using Raphael lib
    Renderer.Raphael = function(canvas, doc, width, height) {
        this.width = width || 400;
        this.height = height || 400; // this is minimum
        var selfRef = this;
        this.doc = doc;
        
        this.trees = doc.bundles[0].allTrees();
        this.r = Raphael(canvas, this.width, this.height);
        
        _.each(this.trees, Layout.Tred);
        
        this.calculateTreesLayout();
        this.adjustCanvasSize();
    };
    
    treex.Raphael = function(canvas, doc, width, height) { return new Renderer.Raphael(canvas, doc, width, height); }
    
    Renderer.Raphael.prototype = {
        dump: function() {
            console.log(this);
        },
        
        defaultRenderNode : function(r, node) {
            var color = Raphael.getColor();
            var bg_rect = r.rect(0, 3, 0, 0).attr({fill: '#FFF',"stroke-width": "0", stroke: '#FFF'});
            var circle = r.circle(0, 0, 3).attr({fill: color, stroke: color, "stroke-width": 2});
            //var text = r.text(0, 11, node.label || node.id);
            var text = r.text(0, 11, node.point[0] + "x" + node.point[1]);
            var box = text.getBBox();
            bg_rect.attr({x: box.x, y: box.y, width: box.width, height: box.height });
            /* set DOM node ID */
            circle.node.id = node.id;
            var shape = r.set().
                push(circle).
                push(text).
                push(bg_rect);
            return shape;
        },
        
        /*
         * Tree placement layout
         */
        calculateTreesLayout: function() {
            if (this.trees.length <= 1)
                return;
            
            if (this.layoutsConfig) {
                // TODO: make layouts configurable
            }
            
            var counter = 0,
            offsetX = 0,
            offsetY = 0;
            for (var i in this.trees) {
                var tree = this.trees[i];
                var c = 0;
                var depth = 1;
                for (var j in tree.nodes) {
                    var n = tree.nodes[j];
                    // TODO: rewrite this
                    if (n.level() > depth) depth = n.level();
                    c++;
                }
                tree.width = 30*(c-1);
                tree.height = 35*depth;
                tree.OffsetX = offsetX;
                tree.OffsetY = 0; // offsetY;
                
                offsetX += tree.width;
                offsetY += tree.height;
                tree.radius = 40;
            }
        },
        
        adjustCanvasSize: function() {
            var width = 0, height = 0;
            _.each(this.trees, function(tree) {
                width += tree.width;
                height = Math.max(height, tree.height);
            });
            
            this.width = width;
            this.height = height;
            this.r.setSize(width, height);
        },
        
        translate: function(point) {
            return [
                (point[0] - this.tree.layoutMinX) * this.factorX + this.tree.OffsetX,
                (point[1] - this.tree.layoutMinY) * this.factorY + this.tree.OffsetY
            ];
        },
        
        rotate: function(point, length, angle) {
            var dx = length * Math.cos(angle);
            var dy = length * Math.sin(angle);
            return [point[0]+dx, point[1]+dy];
        },
        
        draw: function() {
            for (var i in this.trees) {
                this.tree = this.trees[i];
                this.factorX = (this.tree.width) / (this.tree.layoutMaxX - this.tree.layoutMinX);
                this.factorY = (this.tree.height) / (this.tree.layoutMaxY - this.tree.layoutMinY);
                for (var j in this.tree.nodes) {
                    this.drawNode(this.tree.nodes[j]);
                }
                for (j = 0; j < this.tree.edges.length; j++) {
                    this.drawEdge(this.tree.edges[j]);
                }
            }
        },
        
        drawNode: function(node) {
            var point = this.translate([node.layoutPosX, node.layoutPosY]);
            node.point = point;
            /* if node has already been drawn, move the nodes */
            if(node.shape) {
                var oBBox = node.shape.getBBox();
                var opoint = { x: oBBox.x + oBBox.width / 2, y: oBBox.y + oBBox.height / 2};
                node.shape.transform(['t'+Math.round(point[0] - opoint.x), Math.round(point[1] - opoint.y)].join(','));
                this.r.safari(); // fix safari bugs
                return node;
            }/* else, draw new nodes */
            
            var shape;
            
            /* if a node renderer function is provided by the user, then use it
               or the default render function instead */
            if(!node.render) {
                node.render = this.defaultRenderNode;
            }
            
            shape = node.render(this.r, node).hide();
            
            var box = shape.getBBox(true);
            shape.transform(['t'+Math.round(point[0] + box.width/2), Math.round(point[1] + box.height/2)].join(','));
            node.hidden || shape.show();
            node.shape = shape;
            
            return node;
        },
        
        drawEdge: function(edge) {
            if(edge.source.hidden || edge.target.hidden) {
                edge.connection && edge.connection.fg.hide();
                edge.connection.bg && edge.connection.bg.hide();
                return;
            }
            /* if edge already has been drawn, only refresh the edge */
            if(!edge.connection) {
                edge.style && edge.style.callback && edge.style.callback(edge); // TODO move this somewhere else
                edge.connection = this.r.connection(edge.source.shape, edge.target.shape, edge.style);
                return;
            }
            //FIXME showing doesn't work well
            edge.connection.fg.show();
            edge.connection.bg && edge.connection.bg.show();
            edge.connection.draw();
        }
    };

    Layout.prepareTree = function(tree) {
        tree.nodes = _.flatten([tree.root, tree.root.descendants()]);
        tree.edges = [];
        function compute_edges(node) {
            _.each(node.children(), function(child) {
                tree.edges.push({
                    source: node,
                    target: child
                });
                if (!child.is_leaf())
                    compute_edges(child);
            });
        }
        compute_edges(tree.root);
    };
    
    /*
     * Tred like tree layout
     */
    Layout.TredClass = function(tree) {
        Layout.prepareTree(tree);
        this.tree = tree;
        this.order = _.sortBy(tree.nodes, function(n) { return n.order; });
        this.layout();
    };
    
    Layout.Tred = function(tree) { return new Layout.TredClass(tree); };
    
    Layout.TredClass.prototype = {
        layout: function() {
            this.layoutPrepare();
            this.layoutCalcBounds();
        },
        
        layoutPrepare: function() {
            var node, i;
            for (i in this.tree.nodes) {
                node = this.tree.nodes[i];
                node.layoutPosX = 0;
                node.layoutPosY = 0;
            }
            var counter = 0;
            for (i in this.order) {
                node = this.order[i];
                node.layoutPosX = counter;
                node.layoutPosY = node.level();
                counter++;
            }
            
            console.log(this.tree.nodes);
            console.log(this.tree.edges);
        },
            
        layoutCalcBounds: function() {
            var minx = Infinity, maxx = -Infinity, miny = Infinity, maxy = -Infinity;
            
            for (var i in this.tree.nodes) {
                var x = this.tree.nodes[i].layoutPosX;
                var y = this.tree.nodes[i].layoutPosY;
                
                if(x > maxx) maxx = x;
                if(x < minx) minx = x;
                if(y > maxy) maxy = y;
                if(y < miny) miny = y;
            }
            
            this.tree.layoutMinX = minx;
            this.tree.layoutMaxX = maxx;
            
            this.tree.layoutMinY = miny;
            this.tree.layoutMaxY = maxy;
        }
    };
    
    // default options
    var opts = {
        renderNode: Renderer.Raphael.defaultRenderNode,
        renderer: treex.Raphael
    };
    _.extend(treex.opts, opts);
    
})(this.Treex); // possibility of using different version
