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
    @trees = []
    @displayedNodes = {}
    @displayedFigures = {}

  # render Treex Bundle
  renderBundle: (bundle) ->
    layout = new TreeView.Layout.GridLayout(@canvas)
    @trees = []
    layout.disableReordering()
    @canvas.setLayout(layout)
    for label, zone of bundle.zones
      for layer, tree of zone.trees
        T = new TreeView.Tree(layer, tree)
        _.extend(@displayedNodes, tree.index)
        _.extend(@displayedFigures, T.figures)
        @trees.push T
        @canvas.addFigure(T)
    @showAlignment()
    layout.enableReordering()
    layout.reorderFigures()
    @canvas.adjustSize()
    return

  showAlignment: ->
    arrows = []
    for T in @trees
      for node in T.tree.allNodes()
        continue unless node.attr('alignment')?
        for alignment in node.attr('alignment')
          targetId = alignment['#value']['counterpart.rf']
          target = @displayedNodes[targetId]
          continue unless target
          sourceFig = @displayedFigures[node.uid]
          targetFig = @displayedFigures[target.uid]
          continue unless sourceFig? and targetFig?
          TreeView.Style.TreexStylesheet::drawArrow(sourceFig, targetFig, 'alignment')
    return


namespace = exports ? this

namespace.Treex.TreeView = (canvas) -> new TreeView(canvas)
