###
A Node class
###

class TreeView.NodeFigure extends TreeView.Figure
  constructor: ->
    @bgColor = new Color(255, 255, 255)
    @connections = new ArrayList()
    super

  addConnection: (conn) ->
    @connections.add(conn)
    @attachMoveListener(conn)
    return

  removeConnection: (conn) ->
    @connections.remove(conn)
    @detachMoveListener(conn)
    return

  getConnections: -> @connections

  setCanvas: (canvas) ->
    super canvas
    @connections.each (i, connection) ->
      connection.setCanvas(canvas)
      return
    return

  # Point where to anchor all connection
  getAnchorPoint: ->
    p = @getAbsolutePosition()
    p.x += @getWidth() / 2
    p.y += @getHeight() / 2
    return p