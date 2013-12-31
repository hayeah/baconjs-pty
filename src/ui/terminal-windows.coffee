{div,span,button} = React.DOM
cx = React.addons.classSet

{Tab} = NavTabs = require("../bs/nav-tabs")
TerminalUI = require("./terminal")

# new TerminalWindowsUI(tabs: [{title: "PTY 1", name: "pty1",}])
###
<NavTabs>
  <Tab title="PTY 1">
  </Tab>
  <Tab title="PTY 1">
    <Terminal command="bash">
  </Tab>
</NavTabs>
###

TerminalWindowsUI = React.createClass({
  getInitialState: ->
    {
      # {title: String, id: Integer}
      terms: []

      # unique id for each spawned terminal
      IDCounter: 0
    }
  # getDefaultProps: ->
  # componentWillMount: ->
  # componentDidMount: (rootNode) ->
  # componentWillReceiveProps: (nextProps) ->
  # shouldComponentUpdate: (nextProps,nextState) ->
  # componentWillUpdate: (nextProps,nextState) ->
  # componentDidUpdate: (prevProps,prevState,rootNode) ->
  # componentWillUnmount: ->

  open: (title) ->
    {IDCounter,terms} = @state
    IDCounter += 1

    term = {
      title: title
      id: "pty-#{IDCounter}"
    }
    @setState {
      terms: terms.concat([term])
      IDCounter: IDCounter
    }

  render: ->
    tabs = for {id,title} in @state.terms
      Tab({key: id, title: title}, TerminalUI(key: id, conn: @props.conn))

    navtabs = NavTabs(null,tabs)

    div({}
      navtabs,
      button({className: "btn btn-default", onClick: @open.bind(@,"bash")},"New"))
})

module.exports = TerminalWindowsUI