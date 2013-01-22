
class TreeView.Connection.Router

  route: (conn) ->
    throw "Subclasses must implement the method [route]"
    return

  getDirection: (r, p) ->
    distance = Math.abs(r.x - p.x)
    direction = 3

    i = Math.abs(r.y - p.y)
    if i <= distance
      distance = i
      direction = 0

    i = Math.abs(r.getBottom() - p.y)
    if i <= distance
      distance = i
      direction = 2

    i = Math.abs(r.getRight() - p.x)
    if i < distance
      distance = i
      direction = 1

    return direction

  getStartDirection: (conn) ->
    p = conn.getStartPoint()
    rect = conn.getSource().getOriginalBBox()
    return @getDirection(rect, p)

  getEndDirection: (conn) ->
    p = conn.getEndPoint()
    rect = conn.getTarget().getOriginalBBox()
    return @getDirection(rect, p)