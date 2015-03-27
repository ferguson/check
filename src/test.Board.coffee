Board = require './Board'

board = new Board(64)

board.toString()
console.log '' + board + '\n'

board.randomize()
console.log '' + board + '\n'

board.randomize()
console.log '' + board + '\n'

board = new Board(0)

# speed tests
edge = 0
while edge < 3000
  edge = edge + 1
  if edge > 100 then edge = edge + 99
  if edge > 1000 then edge = edge + 1000
  size = Math.pow(edge, 2)
  console.log "#{edge} edge size (#{size} squares)"
  board = new Board(size)
  console.log 'new done'
  board.randomize()
  console.log 'randomize done'
  console.log ''

  if edge < 100
    console.log '' + board + '\n'




