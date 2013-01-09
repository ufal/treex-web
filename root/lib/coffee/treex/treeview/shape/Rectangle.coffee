###
A Rectangle Figure.
###

class TreeView.Shape.Rectangle extends TreeView.VectorFigure
  constructor: (width, height) ->
    #Corner radius
    @radius = 0;

    super

    unless width? and height?
      @setDimension(50, 50)
    else
      @setDimension(width, height)

  repaint: (attrs) ->
    return if @repaintBlocked is on or @shape is null

    attrs ||= {}
    attrs.width = @getWidth()
    attrs.height = @getHeight()
    attrs.r = @radius
    super attrs
    return

  createShapeElement: ->
    @canvas.paper.rect(@getX(), @getY(), @getWidth(), @getHeight())

  setRadius: (@radius) ->
    @repaint
    return
  getRadius: -> @radius
