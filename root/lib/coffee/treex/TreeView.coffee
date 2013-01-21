###
Main namespace for tree rendering
###

class TreeView
  @Shape = {}
  @Style = {}
  @Layout = {}
  @Connection = {}

  constructor: (@canvasId) ->
    @canvas = new TreeView.Canvas(@canvasId)

  # render Treex Bundle
  renderBundle: (bundle) ->
    layout = new TreeView.Layout.GridLayout(@canvas)
    layout.disableReordering()
    @canvas.setLayout(layout)
    for label, zone of bundle.zones
      for layer, tree of zone.trees
        continue if tree.layer isnt 'p'
        @canvas.addFigure(new TreeView.Tree(layer, tree))
    layout.enableReordering()
    layout.reorderFigures()
    @canvas.adjustSize()
    return

namespace = exports ? this

namespace.Treex.TreeView = (canvas) -> new TreeView(canvas)
