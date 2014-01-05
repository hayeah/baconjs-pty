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
    # Don't do anything. Just a wrapper component.
})

Tabs = React.createClass({
  # getInitialState: ->
  # getDefaultProps: ->
  # componentWillMount: ->
  # componentDidMount: (rootNode) ->
  # componentWillReceiveProps: (nextProps) ->
  # shouldComponentUpdate: (nextProps,nextState) ->
  # componentWillUpdate: (nextProps,nextState) ->
  # componentDidUpdate: (prevProps,prevState,rootNode) ->
  # componentWillUnmount: ->

  onSelected: (i) ->
    tab = @props.children[i]
    tab.props.onSelected?(i)

  render: ->
    tabPanes = []
    navtabs = for tab, i in @props.children
      isActive = tab.props.isSelected
      activecx = cx({active: isActive == true})
      key = i

      title = tab.props.title
      tabPanes.push tabPane = div({key: i, className: "tab-pane #{activecx}"},tab.props.children)
      navtab = li({className: activecx, key: i, onClick: @onSelected.bind(@,i,tab)},a(null,title))


    div(null,
      ul({className: "nav nav-tabs"},navtabs)
      div({ref: "content", className: "tab-content"},tabPanes)
    )
})

Tabs.Tab = Tab
module.exports = Tabs