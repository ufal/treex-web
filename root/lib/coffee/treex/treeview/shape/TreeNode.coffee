
class TreeView.Shape.TreeNode extends TreeView.Shape.Circle
  constructor: (@label) ->
    super 7 # radius set to 7

  setLabel: (@label) ->

  getLable: -> @label
