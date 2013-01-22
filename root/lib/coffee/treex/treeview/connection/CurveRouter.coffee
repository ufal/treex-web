
class TreeView.Connection.CurveRouter extends TreeView.Connection.Router

  route: (conn) ->
    fromPt = new Point(conn.getStartX(), conn.getStartY())
    toPt = new Point(conn.getEndX(), conn.getEndY())

    conn.clearPoints()
    X = (toPt.x - fromPt.x)
    Y = (toPt.y - fromPt.y)
    d = Math.sqrt(X*X + Y*Y) # distance
    mx = (toPt.x + fromPt.x)/2 - Y*(25/d + 0.12)
    my = (toPt.y + fromPt.y)/2 + X*(25/d + 0.12)
    conn.addPoint(new Point(mx, my))

    "M#{fromPt.x} #{fromPt.y}C#{fromPt.x} #{fromPt.y} #{mx} #{my} #{toPt.x} #{toPt.y}"
