# We'll assume that socket.io is reliable. So we are not going to worry about
# heartbeat, and that there won't be message losses. If the underlying socket
# disconnects, the server-side blows away all ptys, and the client side should
# respawn everything on reconnect.
#
# TODO: If the underlying connection goes away, we should respawn pipe on connect.
RxObject = require("../RxObject")

# @type {{rols: Integer, cols: Integer}} PTYSize The dimension of a pty

# @property {Bacon.Property.<PTYSize>} uiPTYSize The maximum allowable size for this pty. If it changes, should request remote pty to resize.
# @property {Bacon.Property.<PTYSize>} rx.PTYSize  The current pipe size. It is the reactive property of remote pty size.

class PTYPipe extends RxObject
  # @param {{size:}} options Options to spawn remote terminal.
  # @param {Bacon.Property.<PTYSize>} uiPTYSize
  constructor: (@conn,@id,@uiPTYSize,@options) ->
    @setRx {
      # is the pty program running?
      isRunning: false

      PTYSize: null
    }
    # all messages passed into this channel
    @rawReader = conn.listen(@id) # .doAction ((data) -> console.log(data))

    # data messages to pipe into terminal
    @dataReader = @rawReader.filter (data) -> typeof data == "string"

    # terminal control messages
    @ctrlReader = @rawReader.filter (data) -> data instanceof Array

    @ctrlReader.onValue (data) => @handleCtrl(data)

    # handles ui resize
    @uiPTYSize.changes().onValue @resize.bind(@)

  handleCtrl: (data) =>
    [type,rest...] = data
    switch type
      when "exit"
        @setRx isRunning: false

  # Spawns a remote terminal
  spawn: () ->
    # use the current ui terminal size
    @uiPTYSize.take(1).onValue (size) =>
      @conn.send "spawn", @id, size, @options, =>
        @setRx {isRunning: true, PTYSize: size}

  resize: (size) ->
    @write ["resize",size], =>
      # downstream resize if remote call is success
      @setRx PTYSize: size

  write: (args...) ->
    @conn.send(@id,args...)

  close: ->
    @conn.send(@id,["close"])

module.exports = PTYPipe