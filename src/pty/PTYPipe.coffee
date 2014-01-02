# We'll assume that socket.io is reliable. So we are not going to worry about
# heartbeat, and that there won't be message losses. If the underlying socket
# disconnects, the server-side blows away all ptys, and the client side should
# respawn everything on reconnect.
#
# TODO: If the underlying connection goes away, we should respawn pipe on connect.
RxObject = require("../RxObject")

class PTYPipe extends RxObject
  constructor: (@conn,@id) ->
    @setRx {
      # is the pty program running?
      isRunning: false
    }
    # all messages passed into this channel
    @rawReader = conn.listen(@id) # .doAction ((data) -> console.log(data))

    # data messages to pipe into terminal
    @dataReader = @rawReader.filter (data) -> typeof data == "string"

    # terminal control messages
    @ctrlReader = @rawReader.filter (data) -> data instanceof Array

    @ctrlReader.onValue (data) => @handleCtrl(data)

  handleCtrl: (data) =>
    [type,args...] = data
    switch type
      when "exit"
        @setRx isRunning: false

  # Spawns a remote terminal
  spawn: ->
    @conn.send "spawn", @id, (id) =>
      @setRx isRunning: true

  write: (data) ->
    @conn.send(@id,data)

  close: ->
    @conn.send(@id,["close"])

module.exports = PTYPipe