
class TreeView.Layout.BottomLocator
  constructor: (@parent) ->

  relocate: (order, figure) ->
    w = @parent.getWidth()
    h = @parent.getHeight()
    stroke = if @parent['getStroke']? then @parent.getStroke() else 0

    bbox = figure.getBoundingBox()
    figure.setPosition(0, h+stroke)
    return