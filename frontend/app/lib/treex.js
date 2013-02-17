/*
 * Michal Sedlak 2012
 */

(function() {
    // Establish the top namespace object, `window` in the browser, or `global` on the server.
    var namespace = this;

    // Underscore.js library is required
    var _ = namespace._;
    // jQuery library for ajax requests
    var $ = namespace.jQuery;

    var treex = { '_' : _, '$' : $ }; // just a namespace with no constructor

    // define all `classes` here
    var Document, Bundle, Zone, Tree, Node;

    namespace['Treex'] = treex; // export treex as Treex

    treex.documents = { }; // hash of loaded documents

    // hardcoded options for now
    treex.opts = {
        print_api : 'http://localhost:3000/print' // url of printing api
    };

    treex.parseStyles = function(styles) {
        var style = { };
        if (!styles) return style;
        // #{name:value}
        var n = styles.match(/#\{[\w-:\.#]+\}/g);
        if (!n) return style;
        for (var i = 0; i < n.length; i++) {
            var val = n[i].slice(2, -1); // kill brackets
            val = val.split(':');

            var name = val[0];
            val = val[1];

            name = name.split('-');
            var cat = name.length > 1 ? name.shift() : "Node";
            name = name.shift();

            if (!style[cat]) style[cat] = { };
            style[cat][name] = val;
        }
        return style;
    };

    treex.loadDoc = function(url, callback) {
        // TODO: use ajax with error callback
        $.getJSON(url, {  }, function(data) {
            console.log(data);
            var doc = Document.fromJSON(data);
            doc.file = url;
            treex.documents[url] = (doc);
            _.isFunction(callback) && callback(doc);
        });
    };

    Document = function() {
        this.bundles = [ ]; // an array, because order matters
        this.file = "";
    };
    treex.Document = Document;
    treex.document = function() { return new Document(); };

    Document.fromJSON = function(json) {
        var doc = new Document();
        _.each(json.bundles, function(bundle) {
            var b = Bundle.fromJSON(bundle);
            b.document = doc;
            doc.bundles.push( b );
        });
        return doc;
    };

    Bundle = function() {
        this.zones = { }; // indexed by `language`-`selector`
        this.document = null;
    };
    treex.Bundle = Bundle;
    treex.bundle = function() { return new Bundle(); };

    Bundle.prototype = {
        allTrees : function() {
            var trees = [];
            _.each(this.zones, function(zone) {
                trees.push(_.toArray(zone.trees));
            });

            return _.flatten(trees);
        }
    };

    Bundle.fromJSON = function(json) {
        var bundle = new Bundle();
        bundle.style = treex.parseStyles(json.style);
        _.each(json.zones, function(zone, label) {
            var z = Zone.fromJSON(zone);
            z.bundle = bundle;
            bundle.zones[label] = z;
        });
        return bundle;
    };

    Zone = function() {
        this.trees = { };
        this.sentence = '';
        this.bundle = null;
    };
    treex.Zone = Zone;
    treex.zone = function() { return new Zone(); };

    Zone.fromJSON = function(json) {
        var zone = new Zone();
        _.each(json.trees, function(tree, layer) {
            var t = zone.trees[layer] = Tree.fromJSON(tree.nodes);
            t.layer = tree.layer;
            t.language = tree.language;
        });
        zone.sentence = json.sentence;
        return zone;
    };

    /*
     * Trees related functions
     */
    // tree is defined by root node
    Tree = function(root) {
        this.root = root;
    };
    treex.Tree = Tree;
    // mask constructor
    treex.tree = function(root) { return new Tree(root); };

    Tree.fromJSON = function(nodes) {
        // index nodes first
        var nodesIndex = {};
        var treeNodes = [];
        var root, node, treeNode = null;
        for (var i = 0, ii = nodes.length; i < ii; i++) {
            node = nodes[i];
            treeNode = new Node(node.id, node.data, node.style);
            treeNode.labels = node.labels;
            treeNode.order = i;
            nodesIndex[node.id] = treeNode;
            treeNodes.push(treeNode);
            if (node.parent === null) {
                root = treeNode;
            }
        }
        if (!root) {
            // this should never happen
            throw "Tree has no root!";
        }
        var tree = new Tree(root);
        // manually assign these
        tree.index = nodesIndex;
        tree.nodes = treeNodes;

        // reconstruct the tree parent/child relations
        for (i = 0, ii = nodes.length; i < ii; i++) {
            treeNode = treeNodes[i];
            node = nodes[i];
            if (node.firstson) {
                treeNode.firstson = nodesIndex[node.firstson];
            }
            if (node.parent) {
                treeNode.parent = nodesIndex[node.parent];
            }
            if (node.rbrother) {
                treeNode.rbrother = nodesIndex[node.rbrother];
            }
        }
        return tree;
    };

    Tree.prototype = {
        allNodes : function() {
            return this.nodes;
        }
    };

    var order = 0;

    Node = function(id, data, style) {
        this.id = id;
        this.data = data || { };
        this.style = treex.parseStyles(style);
        this.parent = null;
        this.lbrother = null;
        this.rbrother = null;
        this.firstson = null; // leftmost son
        this.order = order++;
        this.uid = _.uniqueId('node_'); // globaly unique id
    };
    treex.Node = Node;
    treex.node = function(id, data) { return new Node(id, data); };

    // Try to match function names with Treex::PML::Node
    Node.prototype = {
        is_leaf: function() { return this.firstson == null; },
        is_root: function() { return this.parent == null; },
        root: function() {
            var node = this;
            while (node && node.parent != null) node = node.parent;
            return node;
        },
        attr: function(attr) { return this.data[attr]; },
        // from left to right
        following: function(top) {
            if (this.firstson) {
                return this.firstson;
            }
            var node = this;
            while (node) {
                if (node.uid == top.uid || !node.parent)
                    return null;
                if (node.rbrother)
                    return node.rbrother;
                node = node.parent;
            }
            return null;
        },
        descendants: function() {
            var desc = [];
            var node = this.following(this);
            while (node) {
                desc.push(node);
                node = node.following(this);
            }
            return desc;
        },
        leftmost_descendant: function() {
            var node = this;
            while(node.firstson) {
                node = node.firstson;
            }
            return node;
        },
        rightmost_descendant: function() {
            var node = this;
            while (node.firstson) {
                node = node.firstson;
                while (node.rbrother) {
                    node = node.rbrother;
                }
            }
            return node;
        },
        // depth of the node
        level: function() {
            var level = -1;
            var node = this;
            while (node) {
                node = node.parent;
                level++;
            }
            return level;
        },
        children: function() {
            var children = [];
            var node = this.firstson;
            while (node) {
                children.push(node);
                node = node.rbrother;
            }
            return children;
        }//,
        // attach node to new parent
        // paste_on: function(parent) {
        //     var node = parent.firstson;
        //     if (node && this.order > node.order) {
        //         while(node.rbrother && this.order > node.rbrother.order)
        //             node = node.rbrother;
        //         var rbrother = node.rbrother;
        //         this.rbrother = rbrother;
        //         if (rbrother) rbrother.lbrother = this;
        //         node.rbrother = this;
        //         this.lbrother = node;
        //         this.parent = parent;
        //     } else {
        //         this.rbrother = node;
        //         parent.firstson = this;
        //         this.lbrother = null;
        //         if (node) node.lbrother = this;
        //         this.parent = parent;
        //     }
        // }
    };

}).call(this);
