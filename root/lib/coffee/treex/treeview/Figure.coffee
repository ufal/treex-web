###
A lightweight graphical object. Figures are rendered to a Canvas object.
###

class TreeView.Figure
  constructor: ->
    @id = _.uniqueId('figure_')
    @canvas = @shape = null
    @x = @y = 0
    @width = @height = 5
    @children = new ArrayList()
    @moveListener = new ArrayList()

  setCanvas: (canvas) ->
    if canvas is null and @shape isnt null
      @shape.remove()
      @shape = null

    @canvas = canvas
    @getShapeElement() if @canvas isnt null

    for i in [0...@children.getSize()] by 1
      child = @children.get(i)
      child.figure.setCanvas(canvas)
    return

  getCanvas: -> @canvas

  addFigure: (child, locator) ->
    child.setParent(@)
    entry =
      figure: child
      locator: locator
    @children.add(entry)
    child.setCanvas(@canvas) if @canvas isnt null

    @repaint()
    return

  getChildren: ->
    shapes = new ArrayList()
    @children.each((i, e) =>
      shapes.add(e.figure)
      return
    )
    return shapes

  resetChildren: ->
    @children.each((i, e) -> e.figure.setCanvas(null))
    @children = new ArrayList()
    @repaint()
    return

  getShapeElement: ->
    return @shape if @shape isnt null
    @shape = @createShapeElement()

  createShapeElement: ->
    throw "Inherited class must override the abstract method createShapeElement"

  repaint: (attrs) ->
    return if @repaintBlocked is on or @shape is null
    attrs ||= {}
    @shape.attr(attrs)
    # Relocate all children
    for i in [0...@children.getSize()] by 1
      entry = @children.get(i)
      entry.locator.relocate(i, entry.figure)
    return

  getWidth: -> @width
  getHeight: -> @height

  setDimension: (@width, @height) ->
    @repaint()
    @fireMoveEvent()
    return

  getX: -> @x
  getY: -> @y

  getAbsoluteX: ->
    return unless @parent? then @getX() else @getX()+@parent.getAbsoluteX()
  getAbsoluteY: ->
    return unless @parent? then @getY() else @getY()+@parent.getAbsoluteY()

  getAbsolutePosition: ->
    new Point(@getAbsoluteX(), @getAbsoluteY())

  setPosition: (x, y) ->
    @x = x
    @y = y
    @repaint()
    @fireMoveEvent()
    return

  getBoundingBox: ->
    new Rectangle(@getAbsoluteX(), @getAbsoluteY(), @getWidth(), @getHeight())

  setParent: (@parent) ->
  getParent: -> @parent

  attachMoveListener: (listener) ->
    return if listener is null
    @moveListener.add(listener)
    return

  detachMoveListener: (listener) ->
    return if listener is null
    @moveListener.remove(listener)
    return

  fireMoveEvent: ->
    @moveListener.each (i, item) =>
      item.onOtherFigureIsMoving(@)
    return

  onOtherFigureIsMoving: (other) ->
