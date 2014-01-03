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

NAVBAR_HEIGHT = 42

TerminalWindowsUI = React.createClass({
  mixins: [RxStateMixin]

  getInitialState: ->
    {
      # {title: String, id: Integer}
      terms: []

      # unique id for each spawned terminal
      IDCounter: 0

      isConnected: false

      ## reactive streams
      # size of content area in pixels
      contentSize: null
    }
  # getDefaultProps: ->

  # componentWillMount: ->


  componentDidMount: (rootNode) ->
    console.log "root", rootNode
    wrapper = $(rootNode).parent()
    # get the size of content area
    getContentSize = -> {
      height: wrapper.height() - NAVBAR_HEIGHT
      width: wrapper.width()
    }

    contentSize = Bacon.fromEventTarget(window,"resize").throttle(300).map(getContentSize).toProperty(getContentSize())

    # @setRxState contentSize: contentSize
    @setState contentSize: contentSize

  # componentWillReceiveProps: (nextProps) ->
  # shouldComponentUpdate: (nextProps,nextState) ->
  # componentWillUpdate: (nextProps,nextState) ->
  # componentDidUpdate: (prevProps,prevState,rootNode) ->
  # componentWillUnmount: ->


  # @return {{isConnected: RxProp.<boolean>}}
  getRxState: ->
    {isConnected: @props.conn.status}

  # @param {PTYServer.Program} program
  open: (title,program) ->
    {IDCounter,terms} = @state
    IDCounter += 1

    term = {
      title: title
      id: "pty-#{IDCounter}"
      program: program
    }
    @setState {
      terms: terms.concat([term])
      IDCounter: IDCounter
    }

  render: ->
    tabs = for {id,title,program} in @state.terms
      Tab({key: id, title: title}, TerminalUI(key: id, conn: @props.conn, size: @state.contentSize,program: program))

    navtabs = NavTabs(null,tabs)

    div({},
      # div({},"connection status: #{@state.isConnected}")
      navtabs,
      button({className: "btn btn-default", onClick: @open.bind(@,"bash",{command: "bash"})},"bash")
      button({className: "btn btn-default", onClick: @open.bind(@,"irb",{command: "irb"})},"irb")
      button({className: "btn btn-default", onClick: @open.bind(@,"python",{command: "python"})},"python")
    )
})

module.exports = TerminalWindowsUI