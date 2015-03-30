### jshint eqnull: true, eqeqeq: false, -W030 ###

BoardLogic = require './BoardLogic'
PieceLogic = require './PieceLogic'

board = new BoardLogic(64)

while true
  piece = new PieceLogic(board)
  piece.placeOnBoard(4, 4)
  board.randomize()
  console.log '' + piece
  while piece.executeMove()
    console.log '' + piece
    if piece.checkForLoop()
      console.log "looped after #{piece.history.length} moves. no solution."
      break
    #board.randomize()

  if piece.stillOnBoard()
    console.log "##########"
    continue
  else
    break

console.log '' + piece
console.log "fell off board at #{piece.row}x#{piece.col} after #{piece.history.length} moves."
[lastrow, lastcol] = piece.history[piece.history.length-2]
console.log "last position on board was #{lastrow}x#{lastcol}"
