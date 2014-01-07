noop = (->)
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

module.exports = BaconBuffer