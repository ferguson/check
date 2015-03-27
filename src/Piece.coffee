### jshint eqnull: true, eqeqeq: false, -W030 ###

##
## Piece - the lone checker, to be placed on a Board and manipulated by a Player
##

Piece = class
  constructor: (@board) ->
    unless @ instanceof Piece
      throw new Error 'Board() missing new operator'

    @row = undefined
    @col = undefined
    @history = []


  placeOnBoard: (row, col) ->
    @row = row
    @col = col
    @record()
    return @board.isValidPos(row, col)


  executeMove: ->
    if !@board.isValidPos(@row, @col)
      throw new Error 'invalid current position'
    [newrow, newcol] = @board.nextPos(@row, @col)
    return @placeOnBoard(newrow, newcol)


  undoMove: ->
    if @history.length
      [@row, @col] = @history.pop()
      return [@row, @col]
    else
      return undefined


  stillOnBoard: ->
    return @board.isValidPos(@row, @col)


  checkForLoop: ->
    for [oldrow, oldcol] in @history[0..-2]
      if @row == oldrow and @col == oldcol
        return true
    return false


  currentPos: ->
    return [@row, @col]


  record: ->
    @history.push [@row, @col]


Piece::toString = ->
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


module.exports = Piece