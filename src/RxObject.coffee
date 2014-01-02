# A object with observable properties. It defines Bacon properties under
# the `rx` object property.
class RxObject
  # TODO. should accept bacon properties as values. Use selectLatest, and wrap normal values in Rx.
  setRx: (props) ->
    unless @_rx_buses
      @_rx_buses = {}
      # observable properties
      @rx = @_rx_props = {}

    for key, val of props
      bus = @_rx_buses[key]
      unless bus
        bus = @_rx_buses[key] = new Bacon.Bus()
        @_rx_props[key] = bus.toProperty(val)

      # TODO. plug a stream to bus if value is a stream. push a value if value is a normal value.
      bus.push(val)

module.exports = RxObject