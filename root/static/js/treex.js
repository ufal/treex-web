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
    
    treex.loadDoc = function(file, callback) {
        // TODO: use ajax with error callback
        $.getJSON(this.opts.print_api, { file: file }, function(data) {
            var doc = Document.fromJSON(data);
            treex.documents[file] = doc;
            _.isFunction(callback) && callback(doc);
        });
    };
    
    Document = function() {
        this.bundles = [ ]; // an array, because order matters
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
    
    Bundle.fromJSON = function(json) {
        var bundle = new Bundle();
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
        var root = new Node(json.id, json.data);
        root.order = _.isFinite(json.ord) ? json.ord : 0;
        var tree = new Tree(root);
        
        function traverse(jsnode, parent) {
            !_.isEmpty(jsnode.children) && _.each(jsnode.children, function(child) {
                var node = new Node(child.id, child.data);
                node.order = _.isFinite(child.ord) ? child.ord : 0;
                node.paste_on(parent);
                traverse(child, node);
            });
        }
        traverse(json, root);
        return tree;
    };
    
    Node = function(id, data) {
        this.id = id;
        this.data = data;
        this.parent = null;
        this.lbrother = null;
        this.rbrother = null;
        this.firstson = null; // leftmost son
        this.order = 0;
    };
    treex.Node = function(id, data) { return new Node(id, data); };
    
    // Try to match function names with Treex::PML::Node
    Node.prototype = {
        is_leaf: function() { return _.isEmpty(this.children); },
        is_root: function() { return this.parent == null; },
        root: function() {
            var node = this;
            while(node && node.parent != null) node = node.parent;
            return node;
        },
        // depth of the node
        level: function() {
            var level = -1;
            var node = this;
            while(node != null) {
                node = node.parent;
                level++;
            }
            return level;
        },
        children: function() {
            var children = [];
            var node = this.firstson;
            while(node != null) {
                children.push(node);
                node = node.rbrother;
            }
        },
        // attach node to new parent
        paste_on: function(parent) {
            var node = parent.firstson;
            if (this.order > node.order) {
                while(node.rbrother!=null && this.order > node.rbrother.order)
                    node = node.rbrother;
                var rbrother = node.rbrother;
                this.rbrother = rbrother;
                if (rbrother != null) rbrother.lbrother = this;
                node.rbrother = this;
                this.lbrother = node;
                this.parent = parent;
            } else {
                this.rbrother = node;
                parent.firstson = this;
                this.lbrother = null;
                if (node != null) node.lbrother = this;
                this.parent = parent;
            }
        }
    };
    
}).call(this);