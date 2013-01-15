
class TreeView.Shape.Label extends TreeView.SetFigure

  constructor: (@text) ->
    super
    @text = '' unless @text? and typeof @text is 'string'
    @fontSize = 12
    @fontColor = new Color(0, 0, 0)
    @padding = 1
    @setStroke(0)

  createSet: ->
    @canvas.paper.text(0, 0, @text)

  repaint: (attrs) ->
    return if @repaintBlocked is on or not @shape?

    attrs ||= {}
    attrs['fill-opacity'] = 0.9
    lattrs =
      text: @getText()
      x: @padding # just some padding
      y: @getHeight()/2
      'text-anchor': 'start'
      'font-size': @getFontSize()
      fill: @getFontColor().getHashStyle()
    @svgNodes.attr(lattrs)

    super attrs
    return

  setText: (@text) ->
  getText: -> @text

  setFontSize: (@fontSize) ->
  getFontSize: -> @fontSize

  setFontColor: (color) ->
    @fontColor = Color.colorize(color)
    return
  getFontColor: -> @fontColor

  getWidth: ->
    return 0 if @shape is null
    @svgNodes.getBBox().width

  getHeight: ->
    return 0 if @shape is null
    @svgNodes.getBBox().height
