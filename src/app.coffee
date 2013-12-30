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
  constructor: () ->
    @bus = new Bacon.Bus()
    @inputStream = buffer(@bus) # waitable and resumable bus

    @so = Socket.connect()
    connectEvents = Bacon.fromEventTarget(@so,"connect").map(true)
    disconnectEvents = Bacon.fromEventTarget(@so,"disconnect").map(false)
    @status = connectEvents.merge(disconnectEvents).toProperty().startWith(false)
    @status.onValue (up) =>
      if up
        @inputStream.resume()
      else
        @inputStream.pause()

    # only emit message if buffer is in connected state
    @inputStream.onValue ([type,args...]) =>
      @so.emit type, args...

  # returns a bacon event stream
  listen: (event) ->
    Bacon.fromEventTarget(@so,event)

  send: (type,args...) ->
    @bus.push [type,args...]


class PTYClient
  constructor: (@conn,@id) ->
    @conn.send("spawn",@id)

    @input = conn.listen(@id) # .doAction ((data) -> console.log(data))

  write: (data) ->
    @conn.send(@id,data)


openTerm = (c,id) ->
  pty = new PTYClient(c,id)
  term = new Terminal({
    useStyle: true
    cols: 80
    rows: 30
  })
  div = document.createElement("div")
  wrapper = document.getElementById("terminals")
  wrapper.appendChild(div)
  term.open(div)

  term.on "data", (data) ->
    pty.write(data)

  pty.input.onValue (data) =>
    term.write(data)

main = ->
  c = new Connection()
  c.status.onValue (up) =>
    el = document.getElementById("status")
    el.innerText = if up then "connected" else "disconnected"

  openTerm(c,"pty1")
  openTerm(c,"pty2")
  openTerm(c,"pty3")

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