###
A SetFigure is a composition of different SVG elements.
###

class TreeView.SetFigure extends TreeView.VectorFigure

  constructor: (width, height) ->
    super
    @svgNodes = null

    @originalWidth = null
    @originalHeight = null

    @scaleX = 1
    @scaleY = 1

    @offsetX = 0
    @offsetY = 0

    unless width? and height?
      @setDimension(50, 50)
    else
      @setDimension(width, height)

  setCanvas: (canvas) ->
    if canvas is null and @svgNodes isnt null
      @svgNodes.remove()
      @svgNodes = null

    super canvas
    return

  repaint: (attrs) ->
    return if @repaintBlocked is on or @shape is null

    attrs ||= {}
    attrs.width = @getWidth()
    attrs.height = @getHeight()

    if @originalWidth? and @originalHeight?
      @svgNodes.transform("t#{@getAbsoluteX()},#{@getAbsoluteY()}")

    super attrs
    return

  createShapeElement: ->
    shape = @canvas.paper.rect(@getX(), @getY(), @getWidth(), @getHeight())
    @svgNodes = @createSet()

    bb = @svgNodes.getBBox()
    @originalWidth  = bb.width
    @originalHeight = bb.height

    @offsetX = Math.abs(bb.x)
    @offsetY = Math.abs(bb.y)

    return shape

  createSet: ->
    @cavas.paper.set() # return empty set as default
