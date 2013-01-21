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
  clearPoints: ->
    @basePoints.removeAllElements()
    @lineSegments.removeAllElements()
    @lastPoint = null
    return

  addPoint: (point) ->
    p = new Point(point.x, point.y)
    @basePoints.add(p)
    @lineSegments.add(start: @lastPoint, end: p) if @lastPoint isnt null
    @lastPoint = p
    return

  getPathString: ->
    @calculatePath() unless @svgPathString?
    @svgPathString

  calculatePath: ->
    return if @shape is null

    @svgPathString = "M#{@getStartX()} #{@getStartY()}"
    @basePoints.each (i, p) =>
      @svgPathString += "L#{p.x} #{p.y}"
    @svgPathString += "L#{@getEndX()} #{@getEndY()}"
    return

  repaint: ->
    return if @repaintBlocked is on or @shape is null

    @calculatePath() if @svgPathString is null

    super path: @svgPathString
    return
