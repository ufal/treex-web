###
An object to which a TreeView.Connection will be anchored.
###

class TreeView.ConnectionAnchor
  constructor: (@owner) ->
    unless @owner?
      throw "Missing owner for ConnectionAnchor"

  getX: -> @getLocation().x
  getY: -> @getLocation().y

  getLocation: -> @owner.getAnchorPoint()

  setOwner: (@owner) ->
  getOwner: -> @owner

  getBox: -> @getOwner().getAbsoluteBounds()

  getReferencePoint: -> @getOwner().getAbsolutePosition()
