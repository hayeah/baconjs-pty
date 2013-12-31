{div,span} = React.DOM
cx = React.addons.classSet


TerminalUI = React.createClass({
  getInitialState: ->
    term = new Terminal({
      useStyle: true
      cols: 80
      rows: 30
    })
    return {term: term}

  # getDefaultProps: ->
  # componentWillMount: ->

  componentDidMount: (rootNode) ->
    el = @refs.pty.getDOMNode()
    t = @state.term
    t.open(el)
    t.on "data", (data) =>
      t.write(data)

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