
class TreeView.Shape.Label extends TreeView.SetFigure

  constructor: (@text) ->
    super
    @text = '' unless @text? and typeof @text is 'string'
    @fontSize = 12
    @fontColor = new Color(0, 0, 0)
    @padding = 1
    @opacity = 0.9
    @anchor = 'start'
    @setStroke(0)

  createSet: ->
    @canvas.paper.text(0, 0, @text)

  repaint: (attrs) ->
    return if @repaintBlocked is on or not @shape?

    attrs ||= {}
    lattrs =
      text: @getText()
      x: @padding # just some padding
      y: @getHeight()/2
      'text-anchor': @anchor
      'font-size': @getFontSize()
      fill: @getFontColor().getHashStyle()
    @svgNodes.attr(lattrs)
    super attrs

    # transform based on anchor
    switch @anchor
      when 'middle' then @svgNodes.transform("t#{@getAbsoluteX()+@getWidth()/2-@padding},#{@getAbsoluteY()}")
      when 'end' then @svgNodes.transform("t#{@getAbsoluteX()-@getWidth()+@padding},#{@getAbsoluteY()}")
    return

  setPadding: (@padding) ->
  getPadding: -> @padding

  setAnchor: (@anchor) ->
  getAnchor: -> @anchor

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
    @svgNodes.getBBox().width + @padding*2

  getHeight: ->
    return 0 if @shape is null
    @svgNodes.getBBox().height

  getX: ->
    switch @anchor
      when 'middle' then @x-@getWidth()/2
      when 'end' then @x+@getWidth()
      else @x
