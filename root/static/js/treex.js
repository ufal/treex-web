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

    treex.loadDoc = function(file, callback) {
        // TODO: use ajax with error callback
        $.getJSON(this.opts.print_api, { file: file }, function(data) {
            console.log(data);
            var doc = Document.fromJSON(data);
            doc.file = file;
            treex.documents[file] = (doc);
            _.isFunction(callback) && callback(doc);
        });
    };

    Document = function() {
        this.bundles = [ ]; // an array, because order matters
        this.file = "";
    };
    treex.Document = function() { return new Document(); };

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
    treex.Bundle = function() { return new Bundle(); };

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
    treex.Zone = function() { return new Zone(); };

    Zone.fromJSON = function(json) {
        var zone = new Zone();
        _.each(json.trees, function(tree, layer) {
            zone.trees[layer] = Tree.fromJSON(tree);
            zone.trees[layer].layer = layer;
        });
        zone.sentence = json.sentence;
        return zone;
    };

    /*
     * Trees related functions
     */
    // tree is defined by root node
    // We attach additional data to the trees in plugins
    Tree = function(root) {
        this.root = root;
    };
    // mask constructor
    treex.Tree = function(root) { return new Tree(root); };

    Tree.fromJSON = function(json) {
        var root = new Node(json.id, json.data, json.style);
        root.order = _.isFinite(json.ord) ? json.ord : 0;
        root.labels = json.labels;
        var tree = new Tree(root);
        function traverse(jsnode, parent) {
            !_.isEmpty(jsnode.children) && _.each(jsnode.children, function(child) {
                var node = new Node(child.id, child.data);
                node.order = _.isFinite(child.ord) ? child.ord : 0;
                node.labels = child.labels;
                node.paste_on(parent);
                traverse(child, node);
            });
        }
        traverse(json, root);
        return tree;
    };

    Tree.prototype = {
        allNodes : function() {
            var all = this.root.descendants();
            all.push(this.root);
            return all;
        }
    };

    Node = function(id, data, style) {
        this.id = id;
        this.data = data || { };
        this.style = treex.parseStyles(style);
        this.parent = null;
        this.lbrother = null;
        this.rbrother = null;
        this.firstson = null; // leftmost son
        this.order = 0;
        this.uid = _.uniqueId('node_'); // globaly unique id
    };
    treex.Node = function(id, data) { return new Node(id, data); };

    // Try to match function names with Treex::PML::Node
    Node.prototype = {
        is_leaf: function() { return this.firstson == null; },
        is_root: function() { return this.parent == null; },
        root: function() {
            var node = this;
            while (node && node.parent != null) node = node.parent;
            return node;
        },
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
        },
        // attach node to new parent
        paste_on: function(parent) {
            var node = parent.firstson;
            if (node && this.order > node.order) {
                while(node.rbrother && this.order > node.rbrother.order)
                    node = node.rbrother;
                var rbrother = node.rbrother;
                this.rbrother = rbrother;
                if (rbrother) rbrother.lbrother = this;
                node.rbrother = this;
                this.lbrother = node;
                this.parent = parent;
            } else {
                this.rbrother = node;
                parent.firstson = this;
                this.lbrother = null;
                if (node) node.lbrother = this;
                this.parent = parent;
            }
        }
    };

}).call(this);
