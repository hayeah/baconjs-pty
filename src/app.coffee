1 + 1

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
      @sink = sink # uh... is this the same for all subscribers?

    @downstream.resume = @resume.bind(@)
    @downstream.pause = @pause.bind(@)

    @upstream.subscribe (event) =>
      @yield(event)

  pause: ->
    @isPaused = true

  resume: ->
    @isPaused = false
    if buffer.length > 0
      for e in @buffer
        console.log "drain buffer", e
        @sink(e)

      @buffer = []

  yield: (e) ->
    if @isPaused
      console.log "buffer", @buffer.length, e
      @buffer.push e
    else
      # when is @sink bound? Is it when subscribed to or immediately after fromBinder?
      @sink(e)

# wait buffer stream
buffer = (stream) ->
  (new BaconBuffer(stream)).downstream

class Connection
  constructor: () ->
    @so = Socket.connect()

  # returns a bacon event stream
  listen: (event) ->
    Bacon.fromEventTarget(@so,event)

class HeartBeat
  constructor: (@id,@conn) ->

  listen: ->
    conn.listen("ping")

main = ->
  c = new Connection()
  pings = c.listen("ping")
  bpings = buffer(pings)
  setTimeout (->
    # using "take" causes it to infinte recurse somewhere...
    bpings.onValue (i) =>
      console.log "s1", i
    bpings.resume()

  ), 3000

  # pings.onValue (i) =>
  #   console.log "s2", i

window.onload = main