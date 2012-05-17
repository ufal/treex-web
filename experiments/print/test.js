/*
 * 
 */
$(document).ready(function(){
    var tree = new Tree();

    var n1 = tree.addNode(1);
    var n2 = tree.addNode(2);
    var n3 = tree.addNode(3);
    var n4 = tree.addNode(4);
    var n5 = tree.addNode(5);
    var n6 = tree.addNode(6);
    var n7 = tree.addNode(7);
    var n8 = tree.addNode(8);
    
    tree.addEdge(1, 2);
    tree.addEdge(2, 3);
    tree.addEdge(2, 4);
    tree.addEdge(3, 5);
    tree.addEdge(3, 8);
    tree.addEdge(1, 7);
    tree.addEdge(5, 6);
    
    function assignDepth(root, depth)
    {
        root.level = depth;
        for(var i in root.edges) {
            var e = root.edges[i];
            if (!e.target.level)
                assignDepth(e.target, depth+1);
        }
    }
    assignDepth(n1, 0);
    
    var layout = new Tree.Layout.Tred(tree, [n1, n2, n3, n4, n5, n6, n7, n8]);
    var renderer = new Tree.Renderer.Raphael('canvas', tree, 200, 200);
});