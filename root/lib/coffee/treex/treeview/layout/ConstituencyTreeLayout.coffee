###
This tree layout is used mostly for PTB trees.

- uses ManhattanRouter, lines between terminals and non-terminals are dashed
- terminals are at the bottom
- non-terminals are squared nodes with label inside; terminals are circular nodes, more like classic PDT nodes
###

class TreeView.Layout.ConstituencyTreeLayout extends TreeView.Layout.SimpleTreeLayout
  constructor: (tree) ->
    super tree
    @nodeXSkip = 4

  populateGrid: ->
    @grid = {}
    @order = @tree.getNodes().asArray()
    @maxLevel = _.chain(@order).map((node) -> node.level()).max().value()
    for node, i in @order
      level = if node.is_leaf() then @maxLevel else node.level()
      @grid[level] = {} unless @grid[level]?
      @grid[level][i] = node

  computeOrderWidths: ->
    @orderWidths = {}
    left = 0
    for node, index in @order
      if index == 0
        @orderWidths[index] = left
        continue
      fig = @tree.getFigure(node)
      continue unless fig?
      level = if node.is_leaf() then @maxLevel else node.level()
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
      if not node.is_root() and node.children().length == 1
        left += 15
    return

  getNodePosition: (node) ->
    level = if node.is_leaf() then @maxLevel else node.level()
    posY = @marginY
    for lvl in [0...level] by 1
      posY += @levelHeights[lvl] + @marginY

    orderPos = _.indexOf(@order, node)
    posX = @marginX + orderPos*@marginX + @orderWidths[orderPos]

    new Point(posX, posY)
