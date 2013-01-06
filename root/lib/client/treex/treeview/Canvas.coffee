###
Interactive painting area

Used by TreeView
Based on graphiti by Andreas Herz
###

class TreeView.Canvas
  constructor: (@canvasId) ->
    @html = $("##{@canvasId}")
    @initialWidth = @getWidth()
    @initialHeight = @getHeight()

    # Drawing stuff based on Raphael library
    # http://raphaeljs.com/
    @paper = Raphael(@canvasId, @getWidth, @getHeight)

    @figures = new ArrayList()
    @lines = new ArrayList()

    # TODO see below
    @currentSelection = null
    @zoomFactor = 1.0

  addFigure: (figure) ->
    return if figure.getCanvas() is @
    figure.setCanvas(@)

    if figure instanceof TreeView.Shape.Line
      @lines.add(figure)
    else
      @figures.add(figure)

    figure.repaint()

  removeFigure: (figure) ->
    @figures.remove(figure)
    figure.setCanvas(null)
