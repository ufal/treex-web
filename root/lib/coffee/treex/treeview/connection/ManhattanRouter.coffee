
class TreeView.Connection.ManhattanRouter extends TreeView.Connection.Router

  MINDIST = 20
  TOL = 0.1
  TOLxTOL = 0.01

  route: (conn) ->
    fromPt = new Point(conn.getStartX(), conn.getStartY())
    toPt = new Point(conn.getEndX(), conn.getEndY())
    xDiff = fromPt.x - toPt.x
    yDiff = fromPt.y - toPt.y

    "M#{fromPt.x} #{fromPt.y}L#{toPt.x} #{fromPt.y}L#{toPt.x} #{toPt.y}"


  # route: (conn) ->
  #   fromPt = new Point(conn.getStartX(), conn.getStartY())
  #   fromDir = @getStartDirection(conn)

  #   toPt = new Point(conn.getEndX(), conn.getEndY())
  #   toDir = @getEndDirection(conn)

  #   conn.clearPoints()
  #   buildPoints(conn, toPt, toDir, fromPt, fromDir)

  #   ps = conn.getPoints()
  #   p = ps.get(0)
  #   path = "M#{p.x} #{p.y}"
  #   for i in [1...ps.getSize()] by 1
  #     p = ps.get(i)
  #     path += "L#{p.x} #{p.y}"
  #   return path


  buildPoints = (conn, toPt, toDir, fromPt, fromDir) ->

    UP = 0
    RIGHT = 1
    DOWN = 2
    LEFT = 3

    xDiff = fromPt.x - toPt.x
    yDiff = fromPt.y - toPt.y
    point = toPt
    dir = toDir

    if ((xDiff * xDiff) < TOLxTOL) and ((yDiff * yDiff) < TOLxTOL)
      conn.addPoint(new Point(toPt.x, toPt.y))
      return

    if (fromDir is LEFT)
      if (xDiff > 0) and ((yDiff * yDiff) < TOL) and (toDir is RIGHT)
        point = toPt
        dir = toDir
      else
        if xDiff < 0
          point = new Point(fromPt.x - MINDIST, fromPt.y)
        else if ((yDiff > 0) and (toDir is DOWN)) or ((yDiff < 0) and (toDir is UP))
          point = new Point(toPt.x, fromPt.y)
        else if (fromDir is toDir)
          pos = Math.min(fromPt.x, toPt.x) - MINDIST
          point = new Point(pos, fromPt.y)
        else
          point = new Point(fromPt.x - (xDiff / 2), fromPt.y)

        dir = if xDiff > 0 then UP else DOWN
    else if (fromDir is RIGHT)
      if (xDiff < 0) and ((yDiff * yDiff) < TOL) and (toDir is LEFT)
        point = toPt
        dir = toDir
      else
        if xDiff > 0
          point = new Point(fromPt.x + MINDIST, fromPt.y)
        else if ((xDiff > 0) and (toDir is DOWN)) or ((yDiff < 0) and (toDir is UP))
          point = new Point(toPt.x, fromPt.y)
        else if fromDir is toDir
          pos = Math.max(fromPt.x, toPt.x) + MINDIST
          point = new Point(pos, fromPt.y)
        else
          point = new Point(fromPt.x - (xDiff / 2), fromPt.y)

        dir = if yDiff > 0 then UP else DOWN
    else if (fromDir is DOWN)
      if ((xDiff * xDiff) < TOL) and (yDiff < 0) and (toDir is UP)
        point = toPt
        dir = toDir
      else
        if yDiff > 0
          point = new Point(fromPt.x, fromPt.y + MINDIST)
        else if ((xDiff > 0) and (toDir is RIGHT)) or ((xDiff < 0) and (toDir is LEFT))
          point = new Point(fromPt.x, toPt.y)
        else if fromDir is toDir
          pos = Math.max(fromPt.y, toPt.y) + MINDIST
          point = new Point(fromPt.x, pos)
        else
          point = new Point(fromPt.x, fromPt.y - (xDiff / 2))

        dir = if xDiff > 0 then LEFT else RIGHT
    else if (fromDir is UP)
      if ((xDiff * xDiff) < TOL) and (yDiff > 0) and (toDir is DOWN)
           point = toPt
           dir = toDir
      else
        if yDiff < 0
          point = new Point(fromPt.x, fromPt.y - MINDIST)
        else if ((xDiff > 0) && (toDir is RIGHT)) || ((xDiff < 0) && (toDir is LEFT))
          point = new Point(fromPt.x, toPt.y)
        else if fromDir is toDir
          pos = Math.min(fromPt.y, toPt.y) - MINDIST
          point = new Point(fromPt.x, pos)
        else
          point = new Point(fromPt.x, fromPt.y - (yDiff / 2))

        dir = if xDiff > 0 then LEFT else RIGHT
    buildPoints(conn, point, dir, toPt, toDir)
    conn.addPoint(fromPt)
    return
