##
# Michal Sedlak
#
# Drawing extension for Treex Core
#
##

namespace = exports ? this;

treex = namespace.Treex;

treex.Renderer = (canvas, width, height) ->
  new Renderer(canvas, width, height)

class Style
  @default =
    Tree:
      baseXPos: 15
      baseYPos: 15
    Node:
      color: 'yellow'
      outlineColor: 'black'
      width: 7
      height: 7
      xSkip: 10
      ySkip: 10
      xMargin: 2
      yMargin: 2
    Edge:
      color: 'gray'
      width: 2
      arrow: 'none'
    Line:
      color: 'gray'
      width: 2

class Renderer
  @treesLayout

class TreesLayout
  constructor: (@bundle) ->
    @trees = {}
    for name, zone of @bundle.zones
      for layer, tree of zone.trees
        @trees[layer] = tree
    @calcPlacement()

  buildGrid: ->
    @grid = []
    # TODO: some inteligent sorting
    x = y = 0
    for layer, tree of @trees
      @grid[x] = [] unless @grid[x]

  calcPlacement: ->
    return if @trees.length <= 1

    counter =
    offsetX =
    offsetY = 0
    for layer, tree of @trees
      style = tree.style
      offsetX += style.baseXPos
      offsetY += style.baseYPos

      tree.offsetX = offsetX
      tree.offsetY = 0 # ignore offsetY for now

      offsetX += tree.width
      offsetY += tree.height
    return

class DrawNode
  constructor: (@node) ->
