### jshint eqnull: true, eqeqeq: false, -W030 ###

##
## basic 2d visualization using a React and a <table>
##

React = require 'react'

BoardLogic = require './BoardLogic'
PieceLogic = require './PieceLogic'

main = ->
  size = 8
  board = new BoardLogic( Math.pow(size, 2) ).randomize()
  piece = new PieceLogic(board)
  piece.placeOnBoard(4, 4)
  React.render `<Game size={size} board={board} piece={piece} />`, document.body

module.exports = main

##################################################

BoardSurface = React.createClass
  render: ->
    rows = []
    cols = []
    [piece_row, piece_col] = @props.piece.currentPos()
    @props.board.visit (square, i, row, col) ->
      if col is 1
        rows.push `<tr key={rows.length+1}>{cols}</tr>` if cols?.length
        cols = []
      classNames = "go#{BoardLogic::toUDLR(square)}"
      classNames += if row is piece_row and col is piece_col then ' here' else ''
      key = "#{row}x#{col}"
      cols.push `<td className={classNames} key={key} ></td>`
    rows.push `<tr key={rows.length+1}>{cols}</tr>` if cols.length
    return `<table><tbody>{rows}</tbody></table>`


Game = React.createClass
  getInitialState: ->
    size: this.props.size
    sizeInput: this.props.size
    board: this.props.board
    piece: this.props.piece
    moves: 0

  randomizeIt: ->
    this.setState
      size: this.state.size
      board: this.state.board.randomize()

  changeIt: (e) ->
    console.log 'changeIt', e
    console.log e.target.value
    new_size = e.target.value
    @setState sizeInput: new_size
    if new_size > 1
      @resetBoardSize new_size

  expandIt: ->
    @resetBoardSize @state.size + 1

  reduceIt: ->
    @resetBoardSize @state.size - 1

  resetBoardSize: (new_size) ->
    if new_size >= 0 and new_size <= 200
      this.setState
        size: new_size
        sizeInput: new_size
        board: new BoardLogic( Math.pow(new_size, 2) ).randomize()

  moveNext: ->
    console.log 'moveNext'
    @state.piece.executeMove()
    @setState moves: @state.moves + 1


  render: ->
    `<div className="game-container">
      <div className="game">
        <button onClick={this.randomizeIt}>randomize</button>
        <input type="number" className="size" min="1" max="99"
          onChange={this.changeIt} value={this.state.sizeInput}>
        </input>
        <button onClick={this.moveNext}>next</button>
        <BoardSurface board={this.state.board} piece={this.props.piece} />
      </div>
    </div>`

    # <button onClick={this.reduceIt} disabled={this.state.size < 2}>-</button>

