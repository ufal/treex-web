/*
 * Michal Sedlak 2012
 */

/*
 * Factories
 */
var AbstractNode = function(id) {
    this.id = id;
    this.edges = [];
};

AbstractNode.prototype = {
    hide: function() {
        this.hidden = true;
        this.shape && this.shape.hide(); /* FIXME this is representation specific code and should be elsewhere */
        for(var i in this.edges)
            (this.edges[i].source.id == this.id || this.edges[i].target == this.id) && this.edges[i].hide && this.edges[i].hide();
    },
    show : function() {
        this.hidden = false;
        this.shape && this.shape.show();
        for(var i in this.edges)
            (this.edges[i].source.id == this.id || this.edges[i].target == this.id) && this.edges[i].show && this.edges[i].show();
    }
};

var NodeFactory = function() {};
NodeFactory.prototype = {
    build: function(id, content) {
        var n = new AbstractNode(id);
        jQuery.extend(true, n, content);
        return n;
    }
};

var AbstractEdge = function() { };
AbstractEdge.prototype = {
    hide: function() {
        this.connection.fg.hide();
        this.connection.bg && this.bg.connection.hide();
    }
};
var EdgeFactory = function() {
    this.template = new AbstractEdge();
};
EdgeFactory.prototype = {
    build: function(source, target) {
        var e = jQuery.extend(true, {}, this.template);
        e.source = source;
        e.target = target;
        return e;
    }
};


/*
 * TreexDraw
 *
 * Simple implementation of tree drawing class
 */
var TreexDraw = function() {
    this.root = {};
    this.nodes = {};
    this.edges = [];
    
    this.Node = new NodeFactory();
    this.Edge = new EdgeFactory();
    
    this.width = 200;
    this.height = 400;
};

TreexDraw.prototype = {
    addNode: function(id, content) {
        if(this.nodes[id] == undefined) {
            this.nodes[id] = this.Node.build(id, content);
        }
        return this.nodes[id];
    },
    
    addEdge : function(from, to) {
        var f = this.addNode(from);
        var t = this.addNode(to);
        
        var e = this.Edge.build(f, t);
        this.edges.push(e);
        f.edges.push(e);
        t.edges.push(e);
    }
};

/*
 * Renderer class
 */
TreexDraw.Renderer = {};

/* Moved this default node renderer function out of the main prototype code
 * so it can be override by default */
TreexDraw.Renderer.defaultRenderFunc = function(r, node) {
    /* the default node drawing */
    var color = Raphael.getColor();
    var circle = r.circle(0, 0, 7).attr({fill: color, stroke: color, "stroke-width": 2});
    /* set DOM node ID */
    circle.node.id = node.label || node.id;
    var shape = r.set().
        push(circle).
        push(r.text(0, 15, node.label || node.id));
    return shape;
};


TreexDraw.Renderer.Raphael = function(tree, raphael) {
    this.width = width || 400;
    this.height = height || 400;
    var selfRef = this;
    this.r = Raphael(element, this.width, this.height);
    this.radius = 40; /* max dimension of a node */
    this.tree = tree;
    this.mouse_in = false;
    
    /* TODO default node rendering function */
    if(!this.tree.render) {
        this.tree.render = function() {
            return;
        };
    }
    
    /*
     * Dragging
     */
    this.isDrag = false;
    this.dragger = function (e) {
        this.dx = e.clientX;
        this.dy = e.clientY;
        selfRef.isDrag = this;
        this.set && this.set.animate({"fill-opacity": .1}, 200);
        e.preventDefault && e.preventDefault();
    };
    
    var d = document.getElementById(element);
    d.onmousemove = function (e) {
        e = e || window.event;
        if (selfRef.isDrag) {
            var bBox = selfRef.isDrag.set.getBBox();
            // TODO round the coordinates here (eg. for proper image representation)
            var newX = e.clientX - selfRef.isDrag.dx + (bBox.x + bBox.width / 2);
            var newY = e.clientY - selfRef.isDrag.dy + (bBox.y + bBox.height / 2);
            /* prevent shapes from being dragged out of the canvas */
            var clientX = e.clientX - (newX < 20 ? newX - 20 : newX > selfRef.width - 20 ? newX - selfRef.width + 20 : 0);
            var clientY = e.clientY - (newY < 20 ? newY - 20 : newY > selfRef.height - 20 ? newY - selfRef.height + 20 : 0);
            selfRef.isDrag.set.translate(clientX - Math.round(selfRef.isDrag.dx), clientY - Math.round(selfRef.isDrag.dy));
            //            console.log(clientX - Math.round(selfRef.isDrag.dx), clientY - Math.round(selfRef.isDrag.dy));
            for (var i in selfRef.tree.edges) {
                selfRef.tree.edges[i] &&
                    selfRef.tree.edges[i].connection && selfRef.tree.edges[i].connection.draw();
            }
            //selfRef.r.safari();
            selfRef.isDrag.dx = clientX;
            selfRef.isDrag.dy = clientY;
        }
    };
    d.onmouseup = function () {
        selfRef.isDrag && selfRef.isDrag.set.animate({"fill-opacity": .6}, 500);
        selfRef.isDrag = false;
    };
    this.draw();
};

TreexDraw.Renderer.Raphael.prototype = {
    dump: function() {
        console.log(this);
    },
    
    translate: function(point) {
        return [
            (point[0] - this.tree.layoutMinX) * this.factorX + this.radius,
            (point[1] - this.tree.layoutMinY) * this.factorY + this.radius
        ];
    },
    
    rotate: function(point, length, angle) {
        var dx = length * Math.cos(angle);
        var dy = length * Math.sin(angle);
        return [point[0]+dx, point[1]+dy];
    },
    
    draw: function() {
        this.factorX = (this.width - 2 * this.radius) / (this.tree.layoutMaxX - this.tree.layoutMinX);
        this.factorY = (this.height - 2 * this.radius) / (this.tree.layoutMaxY - this.tree.layoutMinY);
        for (var i in this.tree.nodes) {
            this.drawNode(this.tree.nodes[i]);
        }
        for (i = 0; i < this.tree.edges.length; i++) {
            this.drawEdge(this.tree.edges[i]);
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
            this.r.safari();
            return node;
        }/* else, draw new nodes */
        
        var shape;
        
        /* if a node renderer function is provided by the user, then use it
         or the default render function instead */
        if(!node.render) {
            node.render = TreexDraw.Renderer.defaultRenderFunc;
        }
        
        shape = node.render(this.r, node).hide();
        
        shape.attr({"fill-opacity": .6});
        /* re-reference to the node an element belongs to, needed for dragging all elements of a node */
        shape.items.forEach(function(item){ item.set = shape; item.node.style.cursor = "move"; });
        shape.mousedown(this.dragger);
        
        var box = shape.getBBox();
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

TreexDraw.Layout = {};

TreexDraw.Layout.Tred = function(tree, order) {
    this.tree = tree;
    this.order = order;
    this.layout();
};

TreexDraw.Layout.Tred.prototype = {
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
            node.layoutPosY = node.level;
            counter++;
        }
        
        console.log(this.tree.nodes);
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

