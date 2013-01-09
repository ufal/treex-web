###
A Node class
###

class TreeView.NodeFigure extends TreeView.Figure
  constructor: ->
    @bgColor = new Color(255, 255, 255)
    @connections = new ArrayList()
    super

  getConnections: -> @connections

  setCanvas: (canvas) ->
    super canvas
    @connections.each (i, connection) ->
      connection.setCanvas(canvas)
      return
    return
