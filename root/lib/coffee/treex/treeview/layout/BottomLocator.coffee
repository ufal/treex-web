
class TreeView.Layout.BottomLocator
  constructor: (@parent) ->

  relocate: (order, figure) ->
    w = @parent.getWidth()
    h = @parent.getHeight()

    bbox = figure.getBoundingBox()
    figure.setPosition(w/2 - bbox.width/2, h)
    return