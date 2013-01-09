

class TreeView.Layout.TreeNodeLocator
  constructor: (@treeLayout, @node) ->

  relocate: (order, figure) ->
    @treeLayout.getNodePosition(@node)
