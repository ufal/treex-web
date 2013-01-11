
class TreeView.Style.TreexStylesheet
  constructor: (@tree) ->


  getFigure: (node) ->
    new TreeView.Shape.TreeNode()

  getConnection: (parent, child) ->
    new TreeView.Connection()