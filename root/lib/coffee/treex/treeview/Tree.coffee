###
Holder for a single tree
###

class TreeView.Tree extends TreeView.Figure

  DEFAULT_LAYOUT = TreeView.Layout.SimpleTreeLayout

  DEFAULT_STYLESHEET = TreeView.Style.TreexStylesheet

  constructor: (@layer, @tree) ->
    @nodes = new ArrayList()
    @figures = {}
    @layout = new DEFAULT_LAYOUT(@)
    @style = new DEFAULT_STYLESHEET(@)

    for node, i in @tree.allNodes()
      @addNode(node)

    # Recalculate node placement
    # @layout.calculate(@style)

  addNode: (node) ->
    return if @figures[node.uid]? # Prevent node for being added twice
    @nodes.add(node)
    figure = @style.getFigure(node)
    @figures[node.uid] = figure
    @addFigure(figure, @layout.locator(node))

    if node.hasParent() and @figures[node.parent.uid]?
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

  getNodes: -> @nodes

  getFigure: (node) -> @figures[node.uid]

  getWidth: ->
    @width = 0
    for uid, figure of @figures
      @width += figure.getWidth()
    @width

  getHeight: ->
    @height = 0
    for uid, figure of @figures
      @height += figures.getHeight()
    @height

  createShapeElement: ->
    # Create rectangle as a background
    @canvas.paper.rect(@getX(), @getY(), @getWidth(), @getHeight())

  repaint: (attrs) ->
    return id @repaintBlocked is on or @shape is null

    attrs ||= {}
    attrs.x = @getAbsoluteX()
    attrs.y = @getAbsoluteY()
    attrs.width = @getWidth()
    attrs.height = @getHeight()
    super attrs
    return
