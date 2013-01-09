

class TreeView.Layout.SimpleTreeLayout

  @nodeXSkip = 10
  @nodeYSkip = 5

  @marginX = 2
  @marginY = 2

  constructor: (@tree) ->
    @grid = {}
    @order = []
    @levelHeights = {}

  update: ->
    @grid = {}
    @order = @tree.getNodes().asArray()
    @order.sort (a, b) -> a.order - b.order
    # populate grid
    for node, i in @order
      level = node.level()
      @grid[level] = {} unless @grid[level]?
      @grid[level][i] = node
    @computeLevelHeights()
    return

  computeLevelHeights: ->
    @levelHeights = {}
    maxLevel = -1
    for level of @grid
      level = parseInt(level)
      maxLevel = level if level > maxLevel

    for level in [0..maxLevel] by 1
      @levelHeights[level] = 0
      for node, x of @grid[level]
        figure = @tree.getFigure(node)
        continue if figure is null
        height = figure.getHeight()
        @levelHeights[level] = height if height > @levelHeights[level]
      @levelHeights[level] += @nodeYSkip
    return

  locator: (node) ->
    new TreeView.Layout.TreeNodeLocator(@, node)

  getNodePosition: (node) ->
    level = node.level()
    posY = @marginY
    for lvl in [0...level] by 1
      posY += @levelHeights[lvl] + @marginY

    line = @grid[level]
    index = 0
    for i, n of line
      if n is node
        index = i
        break
    posX = @marginX
    for x in [0...index] by 1 when line[x]?
      n = line[x];
      fig = @tree.getFigure(node)
      continue if fig is null
      posX += fig.getWidth() + @nodeXSkip + @marginX
    new Point(posX, posY)
