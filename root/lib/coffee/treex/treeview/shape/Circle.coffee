
class TreeView.Shape.Circle extends TreeView.Shape.Oval
  constructor: (@radius) ->
    super
    if @radius?
      @setDimension(@radius, @radius)
    else
      @setDimension(50, 50)

  setDimension: (w, h) ->
    if w > h
      super w, w
    else
      super h, h
    return