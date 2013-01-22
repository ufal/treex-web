
class TreeView.Connection.ArrowDecorator
  constructor: () ->
    @width = 16
    @height = 8
    @color = new Color(0, 0, 0)
    @bgColor = new Color(250, 250, 250)

  paint: (paper) ->
    st = paper.set()
#    path = "M 0 0L#{@width} #{-@height/2}L#{@width} #{@height/2} L0 0"
    path = "M 0 0L-18 -4L-16 0L-18 4Z"
    st.push paper.path(path)
    st.attr(
      fill: @bgColor.getHashStyle()
      stroke: @bgColor.getHashStyle()
    )
    return st