{div,span,ul,li,a} = React.DOM
cx = React.addons.classSet

Tab = React.createClass({
  # getInitialState: ->
  # getDefaultProps: ->
  # componentWillMount: ->
  # componentDidMount: (rootNode) ->
  # componentWillReceiveProps: (nextProps) ->
  # shouldComponentUpdate: (nextProps,nextState) ->
  # componentWillUpdate: (nextProps,nextState) ->
  # componentDidUpdate: (prevProps,prevState,rootNode) ->
  # componentWillUnmount: ->
  render: ->
    activecx = cx({active: @props.active == true})
    div({className: "tab-pane #{activecx}"},@props.children)
})

Tabs = React.createClass({
  getInitialState: ->
    {
      selected: 0,
    }
  # getDefaultProps: ->
  # componentWillMount: ->
  # componentDidMount: (rootNode) ->
  # componentWillReceiveProps: (nextProps) ->
  # shouldComponentUpdate: (nextProps,nextState) ->
  # componentWillUpdate: (nextProps,nextState) ->
  # componentDidUpdate: (prevProps,prevState,rootNode) ->
  # componentWillUnmount: ->

  selectTab: (i) ->
    @setState selected: i

  render: ->
    navtabs = for tab, i in @props.children
      active = @state.selected == i
      tab.props.active = active

      title = tab.props.title
      key = i
      licx = cx({active: active == true})
      navtab = li({className: licx, key: i, onClick: @selectTab.bind(@,i)},a(null,title))

    div(null,
      ul({className: "nav nav-tabs"},navtabs)
      div({className: "tab-content"},@props.children))
})

Tabs.Tab = Tab
module.exports = Tabs