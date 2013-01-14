

class TreeView.Connection.DirectRouter

  route: (conn) ->
    "M#{conn.getStartX()} #{conn.getStartY()}L#{conn.getEndX()} #{conn.getEndY()}"