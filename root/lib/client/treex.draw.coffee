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

class Point
  constructor: (@x, @y) ->
    return

class Renderer
  constructor: ->

class TreesLayout
  constructor: (@bundle) ->
    @trees = {}
    for name, zone of @bundle.zones
      for layer, tree of zone.trees
        @trees[layer] = tree
    @buildGrid()

  buildGrid: ->
    @grid = []
    @lookup = {}
    # TODO: some inteligent default sorting
    x = y = 0
    for layer, tree of @trees
      @grid[x] = [] unless @grid[x]
      @grid[x][y] = tree;
      @lookup[layer] = new Point(x, y)
      y++
    return

  treePlacement: (layer) ->
    return null unless @lookup[layer]

    loc = @lookup[layer];
    style = @grid[loc.x][loc.y].style;
    offsetX = style.baseXPos;
    offsetY = style.baseYPos;
    for i in [0..loc.x] by 1
      tree = @grid[i][loc.y]
      continue unless tree
      offsetY += tree.height
    for i in [0..loc.y] by 1
      tree = @grid[loc.x][i]
      continue unless tree
      offsetX += tree.width
    return new Point(offsetX, offsetY)

class DrawNode
  constructor: (@node) ->
    return

class DrawTree
  constructor: (@tree) ->
    return

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
