1 + 1

Socket = io

connect = () ->
  Socket.connect()

main = ->
  so = Socket.connect()
  so.on "ping", (i) ->
    # console.log "ping", i
    so.emit "pong", i


window.onload = main