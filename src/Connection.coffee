class Connection
  # @param {SocketIO} so
  constructor: (@so) ->
    @bus = new Bacon.Bus()
    @buffer = []
    @isConnected = false

    @bus.onValue (args) =>
      @sendRemote args

    # @inputStream = buffer(@bus) # waitable and resumable bus
    connectEvents = Bacon.fromEventTarget(@so,"connect").map(true)
    disconnectEvents = Bacon.fromEventTarget(@so,"disconnect").map(false)
    @status = connectEvents.merge(disconnectEvents).toProperty().startWith(false)

    @status.onValue (up) =>
      @isConnected = up

  # Returns a bacon event stream
  listen: (event) ->
    Bacon.fromEventTarget(@so,event)

  send: (args...) ->
    @bus.push args

  sendRemote: (args) ->
    if !@isConnected
      @buffer.push args
      return

    # drain buffer first
    if @buffer.length > 0
      for bufferedArgs in @buffer
        @so.emit bufferedArgs...
      @buffer.length = 0

    @so.emit args...

module.exports = Connection