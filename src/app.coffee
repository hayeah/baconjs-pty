Socket = io

Connection = require("./Connection")

# TerminalUI = require './ui/terminal'
TerminalWindowsUI = require './ui/TerminalWindowsUI'

openTerms = (c) ->
  rootNode = document.getElementById("terminals")
  React.renderComponent TerminalWindowsUI({
    conn: c
  }), rootNode

main = ->
  so = Socket.connect()
  c = new Connection(so)

  window.terms = terms = openTerms(c)
  terms.open("bash",{command: "bash"})

  return

window.onload = main