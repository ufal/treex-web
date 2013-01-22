
class TreeView.Style.TreexStylesheet

  colors =
    'edge'      : '#555555'
    'coord'     : '#bbbbbb'
    'error'     : '#ff0000'

    'anode'            : '#ff6666'
    'anode_coord'      : '#ff6666'
    'nnode'            : '#ffff00'
    'tnode'            : '#4488ff'
    'tnode_coord'      : '#ccddff'
    'terminal'         : '#ffff66'
    'terminal_head'    : '#90ee90'
    'nonterminal_head' : '#90ee90'
    'nonterminal'      : '#ffffe0'
    'trace'            : '#aaaaaa'
    'current'          : '#ff0000'

    'coref_gram' : '#c05633'
    'coref_text' : '#4c509f'
    'compl'      : '#629f52'
    'alignment'  : '#bebebe'
    'coindex'    : '#ffa500' #orange

    'lex'         : '#006400'
    'aux'         : '#ff8c00'
    'parenthesis' : '#809080'
    'afun'        : '#00008b'
    'member'      : '#0000ff'
    'sentmod'     : '#006400'
    'subfunctor'  : '#a02818'
    'nodetype'    : '#00008b'
    'sempos'      : '#8b008b'
    'phrase'      : '#00008b'
    'formeme'     : '#b000b0'
    'tag'         : '#004048'
    'tag_feat'    : '#7098A0'

    'clause0' : '#ff00ff'         #magenta
    'clause1' : '#ffa500'         #orange
    'clause2' : '#0000ff'         #blue
    'clause3' : '#3cb371'         #MediumSeaGreen
    'clause4' : '#ff0000'         #red
    'clause5' : '#9932cc'         #DarkOrchid
    'clause6' : '#00008b'         #DarkBlue
    'clause7' : '#006400'         #DarkGreen
    'clause8' : '#8b0000'         #DarkRed
    'clause9' : '#008b8b'         #DarkCyan

  coordPattern = /^(ADVS|APPS|CONFR|CONJ|CONTRA|CSQ|DISJ|GRAD|OPER|REAS)$/
  isCoord: (node) ->
    return false unless @layer is 't'
    node?.data.functor? and coordPattern.test(node.data.functor)

  constructor: (@tree) ->
    @layer = @tree.layer.split('-')[1] ? 'a'
    @arrows = new ArrayList()
    console.log @layer
    switch @layer
      when 'p'
        @styleNode = @pnodeStyle
        @styleConnection = @pnodeConnection
      when 't'
        @styleNode = @tnodeStyle
        @styleConnection = @tnodeConnection
      else # default is A layer
        @styleNode = @anodeStyle
        @styleConnection = @anodeConnection

  defaultNode = (label) ->
    fig = new TreeView.Shape.TreeNode(label)
    fig.setDimension(7, 7)
    fig.setStroke(1)
    fig.setColor(colors['edge'])
    return fig

  getFigure: (node) ->
    labels = node.labels ? []
    if @layer is 't'
      for label, i in labels
        labels[i] = label.replace(' ???', '') # clean up garbage
                                              # TODO: find of why there is the garbage
    return @styleNode(node, labels.join("\n"))

  getConnection: (parent, child) ->
    conn = new TreeView.Connection()
    conn.setStroke(2)
    conn.setColor(colors['edge'])
    @styleConnection(conn, parent, child)
    return conn

  drawArrows: (node) ->
    # collect new potential arrows
    for ref_attr in ['coref_gram', 'coref_text', 'compl']
      if node.attr("#{ref_attr}.rf")?
        targets = node.attr("#{ref_attr}.rf")
        targets = [targets] unless _.isArray(targets)
        for target in targets
          targetId = if _.isObject(target) then target['#value'] else target
          @arrows.add(
            source_uid: node.uid
            target_id: targetId
            type: ref_attr
          )
    forRemove = []
    @arrows.each (i, arrow) =>
      source = @tree.getNodeByUid(arrow.source_uid)
      forRemove.push arrow unless source? # non-existent source
      target = @tree.getNodeById(arrow.target_id)
      return unless source? and target?
      sourceFig = @tree.getFigure(source)
      targetFig = @tree.getFigure(target)
      return unless sourceFig? and targetFig?
      @drawArrow(sourceFig, targetFig, arrow.type)
      forRemove.push arrow
      return
    for arrow in forRemove
      @arrows.remove(arrow)
    return

  arrowRouter = new TreeView.Connection.CurveRouter()
  drawArrow: (sourceFig, targetFig, type) ->
    conn = new TreeView.Connection()
    conn.setSource(sourceFig)
    conn.setTarget(targetFig)
    conn.setColor(colors[type])
    conn.setStroke(2)
    conn.setRouter(arrowRouter)
    if type is 'alignment'
      conn.setStroke(1)
      conn.setDashing('- ')
    arrow= new TreeView.Connection.ArrowDecorator(15, 30)
    arrow.bgColor = conn.getColor();
    conn.setTargetDecorator(arrow)
    return

  anodeStyle: (node, label) ->
    fig = defaultNode(label)
    fig.setBackgroundColor(colors['anode']);
    return fig

  anodeConnection: (conn, parent, child) ->
    # use default

  tnodeStyle: (node, label) ->
    fig = defaultNode(label)
    fig.setBackgroundColor(colors['tnode'])
    return fig if node.is_root()
    fig.setNodeShape('rectangle') if node.data.is_generated
    fig.setBackgroundColor(colors['tnode_coord']) if @isCoord(node)
    return fig

  tnodeConnection: (conn, parent, child) ->
    color = colors['edge']
    width = 2
    dash = null

    if child.data.is_member
      if not child.is_root() and @isCoord(parent)
        width = 1
        color = colors['coord']
      else
        color = colors['error']
    else if not child.is_root() and @isCoord(parent)
      color = colors['coord_mod']
    else if @isCoord(child)
      color = colors['coord']
      width = 1

    functor = if child.data.functor? then child.data.functor[0]['#value'] else ''
    if functor.match(/^(PAR|PARTL|VOCAT|RHEM|CM|FPHR|PREC)$/) or (not child.is_root() and parent.is_root())
      width = 1
      dash = '. '
      color = colors['edge']

    conn.setStroke(width)
    conn.setColor(color)
    conn.setDashing(dash)
    return

  pnodeStyle: (node, label) ->
    data = node.data
    terminal = node.is_leaf()

    # For nonterminal we use just Labels as nodes
    fig = if terminal then defaultNode(label) else new TreeView.Shape.Label(label)
    if terminal
      ctype = if data.tag is '-NONE-' then 'trace' else if data.is_head then 'terminal_head' else 'terminal'
      fig.setLabelAlign('middle')
    else
      ctype = if data.is_head then 'nonterminal_head' else 'nonterminal'
      fig.setOpacity(1.0)
      fig.setPadding(2)
      fig.setStroke(1)
      fig.setAnchor('middle')
    fig.setBackgroundColor(colors[ctype])
    return fig

  ptbRouter = new TreeView.Connection.ManhattanRouter()
  pnodeConnection: (conn, parent, child) ->
    conn.setRouter(ptbRouter)
    conn.setStroke(1)
    if child.is_leaf()
      conn.setDashing('- ')
    return
