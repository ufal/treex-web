###
A Connection is the line between two Nodes.
###

class TreeView.Connection extends TreeView.Shape.PolyLine

  DEFAULT_ROUTER = new TreeView.Connection.DirectRouter()

  constructor: ->
    super

    @sourceNode = null
    @targetNode = null

    @sourceDecorator = null
    @startDecoratorSet = null

    @targetDecorator = null
    @endDecoratorSet = null

    @sourceAnchor = new TreeView.ConnectionAnchor(@)
    @targetAnchor = new TreeView.ConnectionAnchor(@)

    @router = DEFAULT_ROUTER

  disconnet: ->
    @sourceNode.detachMoveListener(@) if @sourceNode isnt null
    @targetNode.detachMoveListener(@) if @targetNode isnt null
    return

  reconnect: ->
    @sourceNode.attachMoveListener(@) if @sourceNode isnt null
    @targetNode.attachMoveListener(@) if @targetNode isnt null
    @repaint()
    return

  setRouter: (@router) ->
  getRouter: -> @router

  addFigure: (child, locator) ->
    unless locator instanceof TreeView.Layout.ConnectionLocator
      throw "Locator must implement TreeView.Layout.ConnectionLocator"

    super child, locator
    return

  getStartX: -> @sourceAnchor.getX()
  getStartY: -> @sourceAnchor.getY()

  getEndX: -> @targetAnchor.getX()
  getEndY: -> @targetAnchor.getY()

  calculatePath: ->
    return if @shape is null

    @svgPathString = @router.route(@)
    return

  repaint: (attrs) ->
    return if (@repaintBlocked is on or
               @shape is null or
               !@sourceNode? or !@targetNode?)

    # send connection element always to the back
    @shape.toBack()
    super attrs
    # TODO: fix repainting and path recalc
    @svgPathString = null
    if @targetDecorator? and @endDecoratorSet is null
      @endDecoratorSet = @targetDecorator.paint(@getCanvas().paper)
      @endDecoratorSet.insertAfter(@shape)
    if @sourceDecorator? and @startDecoratorSet is null
      @startDecoratorSet = @sourceDecorator.paint(@getCanvas().paper)
      @startDecoratorSet.insertAfter(@shape)

    if @startDecoratorSet? or @endDecoratorSet?
      sx = @getStartX()
      sy = @getStartY()
      ex = @getEndX()
      ey = @getEndY()
      if @startDecoratorSet?
        if @basePoints.getSize() > 0 # auto assume its bezier curve
          c = @basePoints.getFirstElement()
          p = Raphael.findDotsAtSegment(sx, sy, c.x, c.y, c.x, c.y, ex, ey, 0.05)
          angle = Raphael.angle(sx, sy, p.x, p.y)
        else
          angle = Raphael.angle(sx, sy, ex, ey)
        @startDecoratorSet.transform("r#{angle},#{sx},#{sy} t#{sx} #{sy}")
      if @endDecoratorSet?
        if @basePoints.getSize() > 0
          c = @basePoints.getLastElement()
          p = Raphael.findDotsAtSegment(sx, sy, c.x, c.y, c.x, c.y, ex, ey, 0.95)
          angle = Raphael.angle(ex, ey, p.x, p.y)
        else
          angle = Raphael.angle(ex, ey, sx, sy)
        @endDecoratorSet.transform("r#{angle},#{ex},#{ey} t#{ex} #{ey}")

    return

  setSourceDecorator: (@sourceDecorator) ->
    @repaint()
    return
  getSourceDecorator: -> @sourceDecorator

  setTargetDecorator: (@targetDecorator) ->
    @repaint()
    return
  getTargetDecorator: -> @targetDecorator

  setSource: (node) ->
    # detach from previous node
    if @sourceNode?
      @sourceNode.removeConnection(@)
      @sourceAnchor.setOwner(@)
      @setCanvas(null)

    @sourceNode = node
    node.addConnection(@)
    @sourceAnchor.setOwner(node)
    @setCanvas(node.getCanvas())
    @repaint()
    return

  getSource: -> @sourceNode

  setTarget: (node) ->
    if @targetNode?
      @targetNode.removeConnection(@)
      @targetAnchor.setOwner(@)
      @setCanvas(null)

    @targetNode = node
    node.addConnection(@)
    @targetAnchor.setOwner(node)
    @setCanvas(node.getCanvas())
    @repaint()
    return

  getTarget: -> @targetNode

  onOtherFigureIsMoving: (other) ->
    if other is @sourceNode or other is @targetNode
      @repaint()
    return
