{div,span} = React.DOM
cx = React.addons.classSet


PTYPipe = require("../pty/PTYPipe")
PTYSession = require("../pty/PTYSession")

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
    sesion = @connectPTY(term,ptySize)

  # Spawns a session using the current pty size
  # @return {null}
  connectPTY: (term,ptySize) ->
    # Propogation of pty size: ui ptysize -> pipe ptysize -> term ptysize
    # + window resize causes component ptysize to change
    # + component ptysize causes pipe ptysize to change, which causes remote ptysize to change
    # + pipe ptysize change causes terminal emulator to resize
    # @state.ptySize.take(1).onValue ({cols,rows}) =>
    pipe = new PTYPipe(@props.conn,@props.key,ptySize)
    resize = (size) ->
      {cols,rows} = size
      term.resize(cols,rows)

    ptySize.take(1).onValue (size) =>
      # console.log "first set size", size
      resize size

    pipe.rx.PTYSize.changes().onValue (size) =>
      # console.log "remote pty-resize", size
      resize size


    ptySession = new PTYSession(pipe,term)
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