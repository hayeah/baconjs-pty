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
    @openPTY()
    @setPTYSize()
    # @observePTYSize()
    @connectPTY()

  # Spawns a session using the current pty size
  # @return {null}
  connectPTY: ->
    # Propogation of pty size: ui ptysize -> pipe ptysize -> term ptysize
    # + window resize causes component ptysize to change
    # + component ptysize causes pipe ptysize to change, which causes remote ptysize to change
    # + pipe ptysize change causes terminal emulator to resize
    term = @state.term
    # @state.ptySize.take(1).onValue ({cols,rows}) =>
    pipe = new PTYPipe(@props.conn,@props.key,@state.ptySize)
    resize = (size) ->
      {cols,rows} = size
      term.resize(cols,rows)

    @state.ptySize.take(1).onValue (size) =>
      # console.log "first set size", size
      resize size

    pipe.rx.PTYSize.changes().onValue (size) =>
      # console.log "remote pty-resize", size
      resize size


    ptySession = new PTYSession(pipe,term)
    @setState session: ptySession
    return

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
    return

  setPTYSize: ->
    el = @refs.pty.getDOMNode()
    cursor = $(el).find(".terminal-cursor")
    cursorSize = [cursor.width(),cursor.height()]
    calculatePTYSize = (contentSize) ->
      w = contentSize.width
      h = contentSize.height
      {
        cols: Math.floor(w / cursorSize[0])
        rows: Math.floor(h / cursorSize[1])
      }

    ptySize = @props.size.map(calculatePTYSize).skipDuplicates((a,b) => a.cols == b.cols && a.rows == b.rows)
    @setState ptySize: ptySize

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