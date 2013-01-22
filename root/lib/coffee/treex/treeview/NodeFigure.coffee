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

  # Point where to anchor all connections
  getAnchorPoint: ->
    p = @getAbsolutePosition()
    p.x += @getWidth() / 2
    p.y += @getHeight() / 2
    return p

  getOriginalBBox: ->
    new Rectangle(@getAbsoluteX(), @getAbsoluteY(), @getWidth(), @getHeight())

  getBoundingBox: ->
    x = @getAbsoluteX()
    y = @getAbsoluteY()
    x2 = x + @getWidth()
    y2 = y + @getHeight()
    for i in [0...@children.getSize()] by 1
      entry = @children.get(i)
      fig = entry.figure
      fx = fig.getAbsoluteX()
      fy = fig.getAbsoluteY()
      fx2 = fx + fig.getBoundingBox().width
      fy2 = fy + fig.getBoundingBox().height
      x = fx if fx < x
      y = fy if fy < y
      x2 = fx2 if fx2 > x2
      y2 = fy2 if fy2 > y2
    return new Rectangle(x, y, x2 - x, y2 - y)
