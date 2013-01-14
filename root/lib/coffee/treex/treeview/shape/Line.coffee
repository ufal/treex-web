###
The base class for all visible elements inside a canvas.
###

class TreeView.Shape.Line extends TreeView.Figure

  DEFAULT_COLOR = new Color(0,0,0)

  constructor: (@startX, @startY, @endX, @endY) ->
    @lineColor = DEFAULT_COLOR
    @stroke = 1
    super

  getStartX: -> @startX
  getStartY: -> @startY

  getEndX: -> @endX
  getEndY: -> @endY

  getStartPoint: -> new Point(@getStartX(), @getStartY())
  getEndPoint: -> new Point(@getEndX(), @getEndY())

  setStartPoint: (x, y) ->
    return if @startX == x and @startY == y

    @startX = x
    @startY = y
    @repaint()
    return

  setEndPoint: (x, y) ->
    return if @endX == x and @endY == y

    @endX = x
    @endY = y
    @repaint()
    return

  getSegments: ->
    res = new ArrayList()
    res.add(
      start: @getStartPoint()
      end: @getEndPoint()
    )
    return res

  getLength: ->
    # Use native method if possible
    return @shape.getTotalLength() if @shape isnt null
    Math.sqrt((@startX-@endX)*(@startX-@endX)+(@startY-@endY)*(@startY-@endY))

  getPathString: ->
    "M#{@getStartX()} #{@getStartY()}L#{@getEndX()} #{@getEndY()}"

  createShapeElement: ->
    @canvas.paper.path(@getPathString())

  repaint: (attrs) ->
    return if @repaintBlocked is on or @shape is null

    unless attrs?
      attrs =
        'stroke': @lineColor.getHashStyle()
        'stroke-width': @stroke
        'path': @getPathString()
    else
      attrs.path ?= @getPathString()
      attrs.stroke = @lineColor.getHashStyle()
      attrs['stroke-width'] = @stroke

    super attrs
    return

  setStroke: (@stroke) ->
  getStroke: -> @stroke

  setColor: (color) ->
    if color instanceof Color
      @lineColor = color
    else if typeof color is 'string'
      @lineColor = new Color(color)
    else
      @lineColor = DEFAULT_COLOR

    @repaint()
    return

  getColor: -> @lineColor
