{div,span} = React.DOM
cx = React.addons.classSet

class PTYPipe
  constructor: (@conn,@id) ->
    @conn.send("spawn",id)

    @readable = conn.listen(@id) # .doAction ((data) -> console.log(data))

  write: (data) ->
    @conn.send(@id,data)


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

    pipe.readable.onValue (data) =>
      t.write(data)

    t.on "data", (data) =>
      pipe.write(data)

    @setState pipe: pipe

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