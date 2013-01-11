###
An object to which a TreeView.Connection will be anchored.
###

class TreeView.ConnectionAnchor
  constructor: (@owner) ->
    unless @owner?
      throw "Missing owner for ConnectionAnchor"

  getLocation: (reference) -> @getReferencePoint()

  setOwner: (@owner) ->
  getOwner: -> @owner

  getBox: -> @getOwner.getAbsoluteBounds()

  getReferencePoint: -> @getOwner.getAbsolutePosition()
