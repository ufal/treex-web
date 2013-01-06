###
Holder for a single tree
###

class TreeView.Tree extends TreeView.Figure

  DEFAULT_LAYOUT = TreeView.Layout.SimpleTreeLayout

  DEFAULT_STYLESHEET = TreeView.Style.TreexStylesheet

  constructor: (@layer) ->
    @nodes = new ArrayList()
    @figures = {}
    @layout = new DEFAULT_LAYOUT(@)
    @style = new DEFAULT_STYLESHEET(@)

  addNode: (node) ->
    @nodes.add(node)
    figure = @style.getFigure(node)
    @figures[node.uid] = figure
    if node.hasParent() and @figures[node.parent.uid]?
      parentFigure = @figures[node.parent.uid]
      connection = @style.getConnection(node.parent, node)
      if connection?
        connection.setSource(parentFigure)
        connection.setTarget(figure)

    @addFigure(figure, @layout.locator(node))
    return

  addNodes: (list) ->
    @addNode node for node in list
    return

  getNodes: -> @nodes

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
