
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


  constructor: (@tree) ->
    @layer = @tree.layer.split('-')[1] ? 'a'
    console.log @layer
    switch @layer
      when 'x'
#      when 't'
#        @styleNode = @tnodeStyle
#        @styleConnection = @tnodeConnection
      else # default is A layer
        @styleNode = @anodeStyle
        @styleConnection = @anodeConnection

  getFigure: (node) ->
    labels = node.labels ? []
    fig = new TreeView.Shape.TreeNode(labels.join("\n"))
    fig.setStroke(1)
    fig.setColor(colors['edge'])
    @styleNode(fig, node)
    return fig

  getConnection: (parent, child) ->
    conn = new TreeView.Connection()
    conn.setStroke(2)
    conn.setColor(colors['edge'])
    return conn

  anodeStyle: (fig, node) ->
    fig.setBackgroundColor(colors['anode']);
    return

  anodeConnection: (fig, node) ->
