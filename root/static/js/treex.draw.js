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
    Renderer.Raphael = function(canvas, width, height) {
        this.width = width || 400;
        this.height = height || 400; // this is minimum
        
        this.r = Raphael(canvas, this.width, this.height);        
    };

    treex.Renderer = function(canvas, width, height) { return new Renderer.Raphael(canvas, width, height); };

    Renderer.Raphael.defaultRenderNode = function(r, style, pos) {
        var node = style.node;
        var color = style.color || Raphael.getColor();
        var bg_rect = r.rect(0, 3, 0, 0).attr({fill: '#FFF',"stroke-width": "0", stroke: '#FFF'});
        var circle = r.circle(0, 0, 3).attr({fill: color, stroke: color, "stroke-width": 2});
        //var text = r.text(0, 11, node.label || node.id);
        var text = r.text(0, 11, pos[0] + "x" + pos[1]);
        var box = text.getBBox();
        bg_rect.attr({x: box.x, y: box.y, width: box.width, height: box.height })
        /* set DOM node ID */
        circle.node.id = node.id;
        var shape = r.set().
            push(circle).
            push(text).
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
        
        // node passed is a wrapped node object from Style
        // Access underlying node as node.node
        drawNode: function(node, style) {
            var layout = style.layout;
            
            var point = layout.translate(node.node);            
            
            // node has already been drawn, move the nodes
            if(node.shape) {
                var oBBox = node.shape.getBBox();
                var opoint = { x: oBBox.x + oBBox.width / 2, y: oBBox.y + oBBox.height / 2};
                node.shape.transform(['t'+Math.round(point[0] - opoint.x), Math.round(point[1] - opoint.y)].join(','));
                this.r.safari(); // fix safari bugs
                return node;
            }
            
            var shape;
            
            /* if a node renderer function is provided by the style, then use it
               or the default render function instead */
            if(!node.render) {
                node.render = Renderer.Raphael.defaultRenderNode;
            }
            
            shape = node.render(this.r, node, point).hide();
            
            var box = shape.getBBox(true);
            shape.transform(['t'+Math.round(point[0] + box.width/2), Math.round(point[1] + box.height/2)].join(','));
            node.hidden || shape.show();
            node.shape = shape;
            
            return node;
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
            if(Style.styles[tree]) {
                this.style = Style.styles[tree];
            } else if (Style.styles[tree.layer]) {
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
    }
    
    
    treex.Layout = Layout;
    
    Layout.Tred = function(tree) {
        this.tree = tree; // the tree
        this.radius = 15; // node radius
        
        this.nodes = { }; // hash of all nodes
        
        this.width = 400;
        this.height = 400;
        
        this.offsetX = 0;
        this.offsetY = 0;
    };
    
    Layout.Tred.prototype = {
        initialize: function() {
            // sort nodes
            this.order = _.sortBy(this.tree.allNodes(), function(node){ return node.order; });
            this.layoutPrepare();
            this.calcBounds();
            this.calcFactor();
        },
        
        layoutPrepare: function() {
            var i = 0;
            var self = this;
            this.nodes = { }; // clear nodes first
            _.each(this.order, function(n) {
                self.nodes[n.uid] = {
                    layoutPosX : i++,
                    layoutPosY : n.level(),
                    width: 0,
                    height: 0
                };
            });
        },
        
        calcBounds: function() {
            var minx = Infinity, maxx = -Infinity, miny = Infinity, maxy = -Infinity;
            
            _.each(this.nodes, function(node){
                var x = node.layoutPosX;
                var y = node.layoutPosY;
                
                if(x > maxx) maxx = x;
                if(x < minx) minx = x;
                if(y > maxy) maxy = y;
                if(y < miny) miny = y;
            });
            
            this.layoutMinX = minx;
            this.layoutMaxX = maxx;
            
            this.layoutMinY = miny;
            this.layoutMaxY = maxy;
            
            this.width = (maxx-minx) * 2 * this.radius;
            this.height = (maxy-miny) * 2 * this.radius;
        },
        
        calcFactor: function() {
            this.factorX = (this.width - 2 * this.radius) / (this.layoutMaxX - this.layoutMinX);
            this.factorY = (this.height - 2 * this.radius) / (this.layoutMaxY - this.layoutMinY);
        },
        
        translate: function(node) {
            if(!this.nodes[node.uid]) return [0, 0];
            node = this.nodes[node.uid];
            return [
                (node.layoutPosX - this.layoutMinX) * this.factorX + this.radius + this.offsetX,
                (node.layoutPosY - this.layoutMinY) * this.factorY + this.radius + this.offsetY
            ];
        }
    };

    // default options
    var opts = {
        renderNode: Renderer.Raphael.defaultRenderNode,
        renderer: treex.Raphael
    };
    _.extend(treex.opts, opts);    
    
    Style.default = {
        node: { color : '#C80000', hidden : false },
        root: { color : '#000', hidden : false },
        edge: { color : '#000', hidden : false },
        layout : Layout.Tred
    };
    
})(this.Treex); // possibility of using different version
