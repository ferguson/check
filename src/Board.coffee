### jshint eqnull: true, eqeqeq: false ###

require 'buffer'


##
## Board - the playing grid, with squares marked with the direction to move
##

Board = class

  constructor: (@size) ->
    unless @ instanceof Board
      throw new Error 'Board() missing new operator'

    side = Math.floor( Math.sqrt(@size) )  # assuming a square board... for now :)
    @rows = side
    @cols = side
    @squares = new Buffer( @rows * @cols )
    @clear()


  clear: ->
    @map -> '0'
    return @


  randomize: ->
    @map ->
      direction = '1234'[Math.floor( Math.random() * 4 )]
      return direction
    return @


  isValidPos: (row, col) ->
    return false unless row > 0 and row < @rows
    return false unless col > 0 and col < @cols
    return true


  nextPos: (row, col) ->
    return undefined if !@isValidPos(row, col)
    i = @index(row, col)
    direction = @squares[i]
    switch direction
      when 1  # up
        return [row-1, col]
      when 2  # down
        return [row+1, col]
      when 3  # left
        return [row, col-1]
      when 4  # right
        return [row, col+1]
      else  # stay in the same place
        return [row, col]


  # NOTE: unlike the usual map() this modifies the original squares *in place*
  map: (f, arg=null, onlyvisit=false) ->
    for row in [1..@rows]
      for col in [1..@cols]
        i = @index(row, col)
        newval = f(@squares[i], i, row, col, @squares, arg)
        unless onlyvisit
          @squares[i] = newval
    return @

  visit: (f, arg=null) -> @map(f, arg, true)

  index: (row, col) -> (row-1) * @cols + (col-1)

  square: (row, col) -> @squares[ @index(row,col) ]



Board::toString = ->
  return @rowsToStrings().join('\n')


Board::rowsToStrings = ->
  str = ''
  strs = []
  @visit (square, i, row, col) =>
    if col is 1 and row isnt 1
      strs.push(str)
      str = ''
    str += @toUDLR( square )
  strs.push(str)
  return strs


# convert 1..4 to ULDR (up, left, down right)
Board::toUDLR = (n) ->
  # '•' is for squares with '0' (no move)
  return '•UDLR'[Number(n)]


module.exports = Board