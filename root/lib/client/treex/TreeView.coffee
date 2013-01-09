###
Main namespace for tree rendering
###

class TreeView
  @Shape = {}
  @Layout = {}

  constructor: (@canvasId) ->
    @canvas = new TreeView.Canvas(@canvasId)

  # render Treex Bundle
  renderBundle: (bundle) ->
    @canvas.setLayout(new TreeView.Layout.GridLayout())
    for label, zone of bundle.zones
      for layer, tree of zone.trees
        @canvas.addFigure(new TreeView.Tree(layer, tree))
        return # TODO: add only one tree for now
