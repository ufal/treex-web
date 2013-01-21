
class TreeView.Layout.BottomLocator
  constructor: (@parent) ->
    @anchor = 'start'

  relocate: (order, figure) ->
    w = @parent.getWidth()
    h = @parent.getHeight()
    stroke = if @parent['getStroke']? then @parent.getStroke() else 0

    bbox = figure.getBoundingBox()
    switch @anchor
      when 'middle' then x = w/2
      when 'end' then x = w
      else x = 0
    figure.setPosition(x, h+stroke)
    return

  setAnchor: (@anchor) ->
  getAnchor: -> @anchor