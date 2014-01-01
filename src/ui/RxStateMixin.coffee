# Bind component state with Bacon reactive properties.
RxStateMixin = {
  componentWillMount: ->
    @_bindRxState()

  # getRxState: ->
  #   throw "shoud override getRxState"

  # Bind reactive properties to component states
  _bindRxState: ->
    @_RxDiposals =
      for key, rxProp of @getRxState()
        do (key) =>
          rxProp.onValue (val) =>
            change = {}
            change[key] = val
            @setState change

  _unbindRxState: ->
    for dispose in @_RxDiposals
      dispose()
}

module.exports = RxStateMixin