###
Holder for a single tree
###

class TreeView.Tree extends TreeView.Figure

  DEFAULT_LAYOUT = TreeView.Layout.SimpleTreeLayout

  DEFAULT_STYLESHEET = TreeView.Style.TreexStylesheet

  constructor: (@layer, @tree) ->
    super
    @nodes = new ArrayList()
    @figures = {}
    @layout = new DEFAULT_LAYOUT(@)
    @style = new DEFAULT_STYLESHEET(@)

    for node, i in @tree.allNodes()
      @addNode(node)

  setCanvas: (canvas) ->
    super canvas
    # Recalculate node placement
    @layout.update()
    @repaint()
    return

  addNode: (node) ->
    return if @figures[node.uid]? # Prevent node for being added twice
    @nodes.add(node)
    figure = @style.getFigure(node)
    @figures[node.uid] = figure
    @addFigure(figure, @layout.locator(node))

    if !node.is_root() and @figures[node.parent.uid]?
      @connectNodes(node.parent, node)
    for child, i in node.children() when @figures[child.uid]?
      @connectNodes(node, child)
    return

  addNodes: (list) ->
    @addNode node for node in list
    return

  connectNodes: (parent, child) ->
    parentFigure = @figures[parent.uid]
    childFigure = @figures[child.uid]
    return unless parentFigure? and childFigure?
    connection = @style.getConnection(parent, child)
    if connection?
      connection.setSource(parentFigure)
      connection.setTarget(childFigure)
    return

  getNodes: -> @nodes

  getFigure: (node) -> @figures[node.uid]

  getWidth: ->
    @width = 0
    for uid, figure of @figures
      w = figure.getX() + figure.getWidth() + @layout.marginX
      @width = w if w > @width
    @width

  getHeight: ->
    @height = 0
    for uid, figure of @figures
      h = figure.getY() + figure.getHeight() + @layout.marginY
      @height = h if h > @height
    @height

  createShapeElement: ->
    # Create rectangle as a background
    @canvas.paper.rect(@getX(), @getY(), @getWidth(), @getHeight())

  repaint: (attrs) ->
    return if @repaintBlocked is on or @shape is null

    attrs ||= {}
    attrs.x = @getAbsoluteX()
    attrs.y = @getAbsoluteY()
    attrs.width = @getWidth()
    attrs.height = @getHeight()
    super attrs
    return
