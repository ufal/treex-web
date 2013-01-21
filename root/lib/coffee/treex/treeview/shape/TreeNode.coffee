
class TreeView.Shape.TreeNode extends TreeView.VectorFigure
  constructor: (@label) ->
    super
    @shapeName = 'circle'
    # add label
    @labelFigure = new TreeView.Shape.Label(@label)
    @labelLocator = new TreeView.Layout.BottomLocator(@)
    @addFigure(@labelFigure, @labelLocator)

  repaint: (attrs) ->
    return if @repaintBlocked is on or @shape is null

    attrs ||= {}

    w = @getWidth()
    h = @getHeight()
    if @shapeName is 'circle'
      w = h if h > w
      h = w if w > h
    if @shapeName in ['circle', 'ellipse']
      unless attrs.rx? and attrs.ry?
        attrs.rx = w/2
        attrs.ry = h/2
      unless attrs.cx? and attrs.cy?
        attrs.cx = @getAbsoluteX() + attrs.rx
        attrs.cy = @getAbsoluteY() + attrs.ry
    else if @shapeName is 'rectangle'
      attrs.width = w
      attrs.height = h
    super attrs
    return

  createShapeElement: ->
    w = @getWidth()
    h = @getHeight()
    switch @shapeName
      when 'circle'
        r = (if w > h then w else h)/2
        @canvas.paper.circle(@getAbsoluteX()+r, @getAbsoluteY()+r, r)
      when 'ellipse'
        rx = w/2
        ry = h/2
        @canvas.paper.ellipse(@getAbsoluteX()+rx, @getAbsoluteY()+ry, rx, ry)
      when 'rectangle'
        @canvas.paper.rect(@getAbsoluteX(), @getAbsoluteY(), w, h)

  setLabel: (@label) ->
    @labelFigure.setText(@label)
    return
  getLabel: -> @labelFigure

  setLabelAlign: (anchor) ->
    @labelFigure.setAnchor(anchor)
    @labelLocator.setAnchor(anchor)
    return
  getLabelAlign: -> @labelFigure.getAnchor()

  setNodeShape: (@shapeName) ->
  getNodeShape: -> @shapeName
