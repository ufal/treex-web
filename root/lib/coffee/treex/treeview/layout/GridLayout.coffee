
class TreeView.Layout.GridLayout
  constructor: (@canvas) ->
    @figures = new ArrayList()
    @reordering = false
    @margin = 10
    @width = 0
    @height = 0

  add: (figure) ->
    @figures.add(figure)
    figure.attachMoveListener(@)
    @reorderFigures()
    return

  remove: (figure) ->
    @figures.remove(figure)
    figure.detachMoveListener(@)
    @reorderFigures()
    return

  onOtherFigureIsMoving: (other) ->
    @reorderFigures()
    return

  reorderFigures: ->
    return if @reordering
    @reordering = true
    @figures.sort (fig) ->
      return fig.tree?.layer
    left = @margin
    @width = @height = 0
    @figures.each (i, fig) =>
      fig.setPosition(left, 10)
      left += fig.getWidth() + @margin
      h = fig.getAbsoluteY() + fig.getHeight() + @margin
      @height = h if h > @height
      return
    @width = left
    @reordering = false
    return

  getWidth: -> @width
  getHeight: -> @height

  enableReordering: ->
    @reordering = true
    return
  disableReordering: ->
    @reordering = false
    return
