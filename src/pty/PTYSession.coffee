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

  resize: (cols,rows) ->
    @terminal.resize cols, rows


  # TODO throttle spawn.
  spawn: ->
    @pipe.spawn()

  respawn: ->
    @terminal.write("\r\nProgram exited. Restarting\r\n")
    @spawn()


module.exports = PTYSession