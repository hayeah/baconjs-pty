noop = (->)

Socket = io

# Pause and resume bacon events. Buffer events that are fired when pause.
#
class BaconBuffer
  constructor: (@upstream) ->
    @isPaused = true
    @buffer = []
    @cbs = []

    @sink = null
    @downstream = Bacon.fromBinder (sink) =>
      # seems to happen once for multiple onValue subscriptions
      # console.log "got sink"
      @sink = sink # uh... is this the same for all subscribers?
      return noop

    @downstream.resume = =>
      @resume()

    @downstream.pause = =>
      @pause()

    @upstream.subscribe (event) =>
      @yield(event)

  pause: ->
    @isPaused = true

  resume: ->
    @isPaused = false
    if buffer.length > 0
      for e in @buffer
        @sink(e)

      @buffer = []

  yield: (e) ->
    if @isPaused
      # console.log "buffer", @buffer.length, e
      @buffer.push e
    else
      # when is @sink bound? Is it when subscribed to or immediately after fromBinder?
      @sink(e)

# wait buffer stream
buffer = (stream) ->
  (new BaconBuffer(stream)).downstream

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


# TerminalUI = require './ui/terminal'
TerminalWindowsUI = require './ui/TerminalWindowsUI'

openTerms = (c) ->
  rootNode = document.getElementById("terminals")
  React.renderComponent TerminalWindowsUI({
    conn: c
  }), rootNode

main = ->
  so = Socket.connect()
  c = new Connection(so)

  window.terms = terms = openTerms(c)
  terms.open("bash",{command: "bash"})

  return
  pings = c.listen("ping")
  bpings = buffer(pings)
  setTimeout (->
    # using "take" causes it to infinte recurse somewhere...
    bpings.take(10).onValue (i) =>
      console.log "s1", i
    bpings.resume()

  ), 3000

  bpings.take(20).onValue (i) =>
    console.log "s2", i

window.onload = main