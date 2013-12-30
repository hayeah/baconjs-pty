express = require('express')
app = express()
server = require('http').createServer(app)
io = require('socket.io').listen(server)

app.use(express.static(process.cwd()))

PTY = require('pty.js')

class PTYInstance
  constructor: (@id,@so) ->
    @spawn()

  spawn: ->
    @pty = pty = PTY.spawn("bash",[],{
      name: 'xterm-color'
      cols: 80
      rows: 30
      cwd: process.cwd()
      env: process.env
    })

    pty.on 'data', (data) =>
      @so.emit(@id, data)

    @so.on @id, (data) ->
      pty.write(data)

  close: ->

class PTYServer
  constructor: (@so) ->
    @ptys = {}
    @so.on "spawn", (id) =>
      if oldPty = @ptys[id]
        console.log "close", id
        oldPty.close()
      console.log "spawn", id
      @ptys[id] = new PTYInstance(id,@so)

class PingServer
  constructor: (@so) ->
    i = 0
    @timer = setInterval((=>
        i++
        @so.emit("ping",i)
      ),500
    )
    @so.on "pong", (i) ->
      console.log "pong", i

  close: ->
    clearInterval(@timer)

io.sockets.on 'connection', (so) ->
  console.log "new connection"
  new PingServer(so)
  new PTYServer(so)

port = 4000
console.log "Process #{process.pid} listening on #{port}"
server.listen(4000);