
class TreeView.Shape.Oval extends TreeView.VectorFigure
  constructor: (width, height) ->
    super
    if width? and height?
      @setDimension(width, height)
    else
      @setDimension(50, 50)

  createShapeElement: ->
    halfW = @getWidth()/2
    halfH = @getHeight()/2
    @canvas.paper.ellipse(@getAbsoluteX()+halfW, @getAbsoluteY()+halfH, halfW, halfW)

  repaint: (attrs) ->
    return if @repaintBlocked is on or @shape is null

    attrs ||= {}

    unless attrs.rx? and attrs.ry?
      attrs.rx = @getWidth()/2
      attrs.ry = @getHeight()/2

    unless attrs.cx? and attrs.cy?
      attrs.cx = @getAbsoluteX() + attrs.rx
      attrs.cy = @getAbsoluteY() + attrs.ry

    super attrs
    return
