{div,span} = React.DOM
cx = React.addons.classSet


PTYPipe = require("../pty/PTYPipe")
PTYSession = require("../pty/PTYSession")

###*
@property {Connection} conn A websocket connection
@property {String} key Unique id for this terminal
@property {Object} program specify the program to spawn
###

TerminalUI = React.createClass({
  getInitialState: ->
    return {
      session: null

      # @type {Terminal} Terminal emulator
      term: null

      # @type {Bacon.Property.<{cols: Integer, rows:Integer}>} Current PTY dimensions
      ptySize: null
    }

  # getDefaultProps: ->
  # componentWillMount: ->

  componentDidMount: (rootNode) ->
    term = @openPTY()
    ptySize = @setPTYSize(term)
    session = @connectPTY(term,ptySize)

  # Spawns a session using the current pty size
  # @return {null}
  connectPTY: (term,ptySize) ->
    pipe = new PTYPipe(@props.conn,@props.key,@props.program)
    ptySession = new PTYSession(pipe,term,ptySize)
    @setState session: ptySession
    return ptySession

  # Renders the terminal into DOM.
  openPTY: ->
    el = @refs.pty.getDOMNode()
    term = new Terminal({
      useStyle: true
      # cols: @state.cols
      # rows: @state.rows
      cursorBlink: false
    })
    term.open(el)
    @setState term: term
    return term

  setPTYSize: ->
    el = @refs.pty.getDOMNode()
    cursor = $(el).find(".terminal-cursor")
    # cursorSize = [cursor.width(),cursor.height()] # this borks if terminal is not hidden. would be [0,0]
    cursorSize = [7,13] # FIXME: hardwire for now...

    calculatePTYSize = (contentSize) ->
      w = contentSize.width
      h = contentSize.height
      {
        cols: Math.floor(w / cursorSize[0])
        rows: Math.floor(h / cursorSize[1])
      }

    ptySize = @props.size.map(calculatePTYSize).skipDuplicates((a,b) => a.cols == b.cols && a.rows == b.rows)
    @setState ptySize: ptySize
    return ptySize

  # componentWillReceiveProps: (nextProps) ->
  # shouldComponentUpdate: (nextProps,nextState) ->
  # componentWillUpdate: (nextProps,nextState) ->
  # componentDidUpdate: (prevProps,prevState,rootNode) ->

  componentWillUnmount: ->
    t = @state.term
    t.destroy()

  render: ->
    div({ref: "pty"})
})
module.exports = TerminalUI