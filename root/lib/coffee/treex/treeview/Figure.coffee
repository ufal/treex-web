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

  setCanvas: (canvas) ->
    if canvas is null and @shape isnt null
      @shape.remove()
      @shape = null

    @canvas = canvas
    @getShapeElement() if @canvas isnt null

    for i in [i...@children.getSize()] by 1
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
    return

  getX: -> @x
  getY: -> @y

  getAbsoluteX: ->
    return if @parent is null then @x else @x+@parent.getAbsoluteX()
  getAbsoluteY: ->
    return if @parent is null then @y else @y+@parent.getAbsoluteY()

  getAbsolutePosition: ->
    new Point(@getAbsoluteX(), @getAbsoluteY())

  setPosition: (@x, @y) ->
    @repaint()
    return

  getBoundingBox: ->
    new Rectangle(@getAbsoluteX(), @getAbsoluteY(), @getWidth(), @getHeight())

  setParent: (@parent) ->
  getParent: -> @parent
