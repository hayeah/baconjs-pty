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

RxStateMixin = require("./RxStateMixin")

TerminalWindowsUI = React.createClass({
  mixins: [RxStateMixin]

  getInitialState: ->
    {
      # {title: String, id: Integer}
      terms: []

      # unique id for each spawned terminal
      IDCounter: 0

      isConnected: false
    }
  # getDefaultProps: ->
  # componentWillMount: ->

  # componentDidMount: (rootNode) ->
  # componentWillReceiveProps: (nextProps) ->
  # shouldComponentUpdate: (nextProps,nextState) ->
  # componentWillUpdate: (nextProps,nextState) ->
  # componentDidUpdate: (prevProps,prevState,rootNode) ->
  # componentWillUnmount: ->


  # @return {{isConnected: RxProp.<boolean>}}
  getRxState: ->
    {isConnected: @props.conn.status}


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

    div({},
      div({},"connection status: #{@state.isConnected}")
      navtabs,
      button({className: "btn btn-default", onClick: @open.bind(@,"bash")},"New"))
})

module.exports = TerminalWindowsUI