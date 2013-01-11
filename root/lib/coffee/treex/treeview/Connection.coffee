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
    @targetDecorator = null

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

  addFigure: (child, locator) ->
    unless locator instanceof TreeView.Layout.ConnectionLocator
      throw "Locator must implement TreeView.Layout.ConnectionLocator"

    super child, locator
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

  getSource: -> @sourceNode

  setTarget: (@targetNode) ->
  getTarget: -> @targetNode
