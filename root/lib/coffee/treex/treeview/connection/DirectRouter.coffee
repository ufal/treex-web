

class TreeView.Connection.DirectRouter extends TreeView.Connection.Router

  route: (conn) ->
    "M#{conn.getStartX()} #{conn.getStartY()}L#{conn.getEndX()} #{conn.getEndY()}"