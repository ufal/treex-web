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
    @nodesIndex = {}
    if @tree.layer is 'p'
      @layout = new TreeView.Layout.ConstituencyTreeLayout(@)
    else
      @layout = new DEFAULT_LAYOUT(@)
    @style = new DEFAULT_STYLESHEET(@)

    for node, i in @tree.allNodes()
      @addNode(node)

  addNode: (node) ->
    return if @figures[node.uid]? # Prevent node for being added twice
    @nodes.add(node)
    @nodesIndex[node.uid] = node
    figure = @style.getFigure(node)
    @figures[node.uid] = figure
    @addFigure(figure, @layout.locator(node))

    if !node.is_root() and @figures[node.parent.uid]?
      @connectNodes(node.parent, node)
    for child, i in node.children() when @figures[child.uid]?
      @connectNodes(node, child)
    @style.drawArrows(node)
    return

  addNodes: (list) ->
    @addNode node for node in list
    return

  getNodeById: (id) ->
    @tree.index[id]

  getNodeByUid: (uid) ->
    @nodesIndex[uid]

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

  getWidth: -> @layout.getTotalWidth()

  getHeight: -> @layout.getTotalHeight()

  createShapeElement: ->
    # Create rectangle as a background
    @canvas.paper.rect(@getX(), @getY(), @getWidth(), @getHeight())

  repaint: (attrs) ->
    return if @repaintBlocked is on or @shape is null

    @layout.update()
    for i in [0...@children.getSize()] by 1
      entry = @children.get(i)
      entry.locator.relocate(i, entry.figure)

    attrs ||= {}
    attrs.x = @getAbsoluteX()
    attrs.y = @getAbsoluteY()
    attrs.width = @getWidth()
    attrs.height = @getHeight()
    @shape.attr(attrs)
    return
