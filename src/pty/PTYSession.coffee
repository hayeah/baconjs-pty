RESPAWN_LIMIT = 3
# A PTY session running on a pipe. It respawns itself on exit.
class PTYSession
  # @param {PTYPipe} pipe
  # @param {Terminal} terminal Client side terminal object.
  constructor: (@pipe,@terminal) ->
    @spawn()

    @pipe.dataReader.onValue (data) =>
      @terminal.write(data)

    respawnEvents = @pipe.rx.isRunning.
      changes().
      skipDuplicates().
      filter((isRunning) -> isRunning == false)

    respawnEvents.take(RESPAWN_LIMIT).onValue =>
      @respawn()

    respawnEvents.skip(RESPAWN_LIMIT).take(1).onEnd =>
      @terminal.write("\r\nProgram restarted #{RESPAWN_LIMIT} times. Will not restart again.\r\n")

    @terminal.on "data", (data) =>
      @pipe.write(data)

  # TODO throttle spawn.
  spawn: ->
    @pipe.spawn()

  respawn: ->
    @terminal.write("\r\nProgram exited. Restarting\r\n")
    @spawn()

  # i guess this is an abstraction leak here. It would be better if PTYSession
  # doesn't know about "exit" message. Session should just observe the "isConnected" property.
  handleCtrl: (data) ->
    [type,args...] = data
    switch type
      when "exit"
        @respawn()

module.exports = PTYSession