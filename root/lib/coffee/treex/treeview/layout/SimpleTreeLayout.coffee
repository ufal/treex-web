

class TreeView.Layout.SimpleTreeLayout

  nodeXSkip: 10
  nodeYSkip: 5

  marginX: 2
  marginY: 2

  constructor: (@tree) ->
    @grid = {}
    @order = []
    @levelHeights = {}
    @orderWidths = {}

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
    @computeOrderWidths()
    return

  computeLevelHeights: ->
    @levelHeights = {}
    maxLevel = -1
    for level of @grid
      level = parseInt(level)
      maxLevel = level if level > maxLevel

    for level in [0..maxLevel] by 1
      @levelHeights[level] = 0
      for x, node of @grid[level]
        figure = @tree.getFigure(node)
        continue unless figure?
        height = figure.getBoundingBox().height
        @levelHeights[level] = height if height > @levelHeights[level]
      @levelHeights[level] += @nodeYSkip
    return

  computeOrderWidths: ->
    @orderWidths = {}
    left = 0
    for node, index in @order
      if index == 0
        @orderWidths[index] = left
        continue
      fig = @tree.getFigure(node)
      continue unless fig?
      level = node.level()
      leftWidth = 0
      for i in [index-1..0] by -1
        n = @grid[level][i]
        continue unless n?
        f = @tree.getFigure(n)
        continue unless f?
        leftWidth = @orderWidths[i] + f.getBoundingBox().width
        break
      if leftWidth >= left
        left = leftWidth + @nodeXSkip
      else
        left += @nodeXSkip
      @orderWidths[index] = left
    return

  getTotalWidth: ->
    width = 0
    for node, index in @order
      f = @tree.getFigure(node)
      continue unless f?
      w = @orderWidths[index] + (index+2)*@marginX + f.getBoundingBox().width
      width = w if w > width
    return width

  getTotalHeight: ->
    height = 0
    for i, val of @levelHeights
      height += val + @marginY
    return height

  locator: (node) ->
    new TreeView.Layout.TreeNodeLocator(@, node)

  getNodePosition: (node) ->
    level = node.level()
    posY = @marginY
    for lvl in [0...level] by 1
      posY += @levelHeights[lvl] + @marginY

    orderPos = _.indexOf(@order, node)
    posX = @marginX + orderPos*@marginX + @orderWidths[orderPos]

    new Point(posX, posY)
