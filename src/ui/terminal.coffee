{div,span} = React.DOM
cx = React.addons.classSet


PTYPipe = require("../pty/PTYPipe")
PTYSession = require("../pty/PTYSession")

TerminalUI = React.createClass({
  getInitialState: ->
    term = new Terminal({
      useStyle: true
      cols: 80
      rows: 30
    })
    return {
      term: term
      pipe: null
    }

  # getDefaultProps: ->
  # componentWillMount: ->

  componentDidMount: (rootNode) ->
    el = @refs.pty.getDOMNode()
    t = @state.term
    t.open(el)

    pipe = new PTYPipe(@props.conn,@props.key)
    ptySession = new PTYSession(pipe,@state.term)

    @setState session: ptySession

  # componentWillReceiveProps: (nextProps) ->
  # shouldComponentUpdate: (nextProps,nextState) ->
  # componentWillUpdate: (nextProps,nextState) ->
  # componentDidUpdate: (prevProps,prevState,rootNode) ->

  componentWillUnmount: ->
    t = @state.term
    t.destroy()

  render: ->
    div(null,
      div({ref: "pty"})
    )
})
module.exports = TerminalUI