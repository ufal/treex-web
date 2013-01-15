
class TreeView.Shape.TreeNode extends TreeView.Shape.Circle
  constructor: (@label) ->
    super 7 # radius set to 7
    # add label
    @labelFigure = new TreeView.Shape.Label(@label)
    @addFigure(@labelFigure, new TreeView.Layout.BottomLocator(@))

  setLabel: (@label) ->
    @labelFigure.setText(@label)
    return

  getLable: -> @label
