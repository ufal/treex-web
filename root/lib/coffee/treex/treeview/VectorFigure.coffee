###
The base class for all vector based figures
###

class TreeView.VectorFigure extends TreeView.NodeFigure
  constructor: ->
    @bgColor = new Color(255, 255, 255)
    @color = new Color(0, 0, 0)
    @stroke = 1
    @opacity = 1.0
    super

  repaint: (attrs) ->
    return if @repaintBlocked is on or @shape is null

    attrs ||= {}
    attrs.x = @getAbsoluteX()
    attrs.y = @getAbsoluteY()

    attrs.stroke ?= if @color? and @stroke is 0 then 'none' else @color.getHashStyle()
    attrs['stroke-width'] ?= @stroke
    attrs['fill-opacity'] ?= @opacity if @opacity isnt 1.0
    attrs.fill ?= if @bgColor? then @bgColor.getHashStyle() else 'none'
    super attrs
    return

  setBackgroundColor: (color) ->
    @bgColor = Color.colorize(color)
    @repaint()
    return
  getBackgroundColor: -> @bgColor

  setOpacity: (@opacity) ->
    @repaint()
    return
  getOpacity: -> @opacity

  setStroke: (@stroke) ->
    @repaint()
    return
  getStroke: -> @stroke

  setColor: (color) ->
    @color = Color.colorize(color)
    @repaint()
    return
  getColor: -> @color
