###
A PolyLine is a line with more than 2 points.
###

class TreeView.Shape.PolyLine extends TreeView.Shape.Line
  constructor: ->
    @svgPathString = null

    # all line segments
    @lineSegments = new ArrayList()
    @basePoints = new ArrayList()
    @lastPoint = null

    super

    @setStroke(1)

  setStartPoint: (x, y) ->
    super x, y
    @calculatePath()
    @repaint()
    return

  setEndPoint: (x, y) ->
    super x, y
    @calculatePath()
    @repaint()
    return

  getPoints: -> @basePoints
  getSegments: -> @lineSegments

  addPoint: (point) ->
    p = new Point(point.x, point.y)
    @basePoints.add(p)
    @lineSegments.add(start: @lastPoint, end: p) if @lastPoint isnt null
    @lastPoint = p
    return

  calculatePath: ->
    return if @shape is null

    @svgPathString = null
    @lineSegments.removeAllElements()
    @basePoints.removeAllElements()

    @router.route(@)
    return

  repaint: ->
    return if @repaintBlocked is on or @shape is null

    @calculatePath() if @svgPathString is null

    super path: @svgPathString
    return
