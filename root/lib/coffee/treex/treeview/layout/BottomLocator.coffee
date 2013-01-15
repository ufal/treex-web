
class TreeView.Layout.BottomLocator
  constructor: (@parent) ->

  relocate: (order, figure) ->
    w = @parent.getWidth()
    h = @parent.getHeight()

    bbox = figure.getBoundingBox()
    figure.setPosition(0, h)
    return