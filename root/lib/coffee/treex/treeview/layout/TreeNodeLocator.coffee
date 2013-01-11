

class TreeView.Layout.TreeNodeLocator
  constructor: (@treeLayout, @node) ->

  relocate: (order, figure) ->
    pos = @treeLayout.getNodePosition(@node)
    console.log pos
    figure.setPosition(pos.x, pos.y)
