
class TreeView.Layout.GridLayout
  constructor: ->
    @figures = new ArrayList()

  add: (figure) ->
    @figures.add(figure)