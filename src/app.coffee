1 + 1

Socket = io

class Connection
  constructor: () ->
    @so = Socket.connect()

  # returns a bacon event stream
  listen: (event) ->
    Bacon.fromEventTarget(@so,event)


main = ->
  c = new Connection()
  setTimeout (->
    c.listen("ping").take(10).onValue (i) =>
      console.log "s1", i
  ), 2000

  c.listen("ping").take(10).onValue (i) =>
    console.log "s2", i

window.onload = main