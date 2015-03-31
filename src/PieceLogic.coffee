##
## PieceLogic - the lone checker, to be placed on a BoardLogic and manipulated by a Player
##

### jshint eqnull: true, eqeqeq: false, -W030 ###


PieceLogic = class
  constructor: (@board) ->
    unless @ instanceof PieceLogic
      throw new Error 'PieceLogic() missing new operator'

    @row = undefined
    @col = undefined
    @history = []


  placeOnBoard: (row, col) ->
    @row = row
    @col = col
    @record()
    return @board.isValidPos(row, col)


  placeRandomlyOnBoard: ->
    @row = Math.floor( Math.random() * @board.rows ) + 1
    @col = Math.floor( Math.random() * @board.cols ) + 1
    @record()
    return @


  executeMove: ->
    if !@board.isValidPos(@row, @col)
      throw new Error 'invalid current position'
    [newrow, newcol] = @board.nextPos(@row, @col)
    return @placeOnBoard(newrow, newcol)


  undoMove: ->
    if @history.length > 1
      @history.pop()
      [@row, @col] = @history[@history.length-1]
      return [@row, @col]
    else
      return undefined


  stillOnBoard: ->
    return @board.isValidPos(@row, @col)


  checkForLoop: (nullifyLoop=false) ->
    for [oldrow, oldcol],n in @history[0..-2]
      if @row == oldrow and @col == oldcol
        if nullifyLoop
          @history = @history.slice(0, n+1)
        return true
    return false


  currentPos: ->
    return [@row, @col]


  record: ->
    @history.push [@row, @col]


PieceLogic::toString = ->
  if not window?
    colour = require 'colour'  # for .inverse
  str = ''
  for row in [0..@board.rows+1]
    for col in [0..@board.cols+1]
      if @board.isValidPos(row, col)
        square = @board.square(row, col)
        c = @board.toUDLR(square).toLowerCase()
      else
        c = ' '
      if @row == row and @col == col
        c = c.toUpperCase()
        if c is ' ' then c = 'X'
        if not window?
          c = c.inverse
      if col is 0 and row isnt 0
        str += '\n'
      str += c
  return str


module.exports = PieceLogic