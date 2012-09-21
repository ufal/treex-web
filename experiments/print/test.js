/*
 * 
 */
$(document).ready(function(){
    var tree = new TreexDraw.Tree();

    var n1 = tree.addNode("b");
    var n2 = tree.addNode("aa");
    var n3 = tree.addNode(3);
    var n4 = tree.addNode(4);
    var n5 = tree.addNode(5);
    var n6 = tree.addNode(6);
    var n7 = tree.addNode(7);
    var n8 = tree.addNode(8);
    
    tree.addEdge(n1.id, n2.id);
    tree.addEdge(n2.id, 3);
    tree.addEdge(n2.id, 4);
    tree.addEdge(3, 5);
    tree.addEdge(3, 8);
    tree.addEdge(n1.id, 7);
    tree.addEdge(5, 6);

    // var tree1 = new TreexDraw.Tree();
    // var tree1_nodes = [];
    // for (var i = 0; i < 10; i ++) {
    //     var node = tree1.addNode(i);
    //     tree1_nodes.push(node);
    // }

    // function randomDepth(root, nodes, depth) {
    //     root.level = depth;
    //     if (nodes.length == 0) return;
    //     var i = Math.floor(Math.random()*nodes.length);
    //     while (i < nodes.length)
    //     {
    //         var node = nodes.splice(i, 1)[0];
    //         node.level = depth+1;
    //         tree1.addEdge(root.id, node.id);
    //         i += Math.floor(Math.random()*nodes.length);
    //     }
    //     randomDepth(node, nodes, depth+1);
    // }
    // sorted_nodes = jQuery.extend([], tree1_nodes);
    // randomDepth(tree1_nodes.shift(), tree1_nodes, 0);
    
    function assignDepth(root, depth) {
        root.level = depth;
        for(var i in root.edges) {
            var e = root.edges[i];
            if (!e.target.level)
                assignDepth(e.target, depth+1);
        }
    }
    assignDepth(n1, 0);
    
    
    var layout = new TreexDraw.TreeLayout.Tred(tree, [n1, n2, n3, n4, n5, n6, n7, n8]);
    //layout = new TreexDraw.TreeLayout.Tred(tree1, sorted_nodes);
    var renderer = new TreexDraw.Renderer.Raphael('canvas', { 1: tree }, 800, 500);
});