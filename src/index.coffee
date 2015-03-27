### jshint eqnull: true, eqeqeq: false, -W030 ###

# 5 quick tips to reading CoffeeScript:
#   indenting automatically adds braces
#     obj =
#       prop1: 1, prop2: 'two'
#     is obj = { prop1: 1, prop2: 'two' }
#   -> is a function call (and => is a function call but binds 'this')
#     (x, y) -> is function(x, y), -> alone is just function() {}
#   @ is just an alias for 'this'
#     read @prop as this.prop
#   a space after a token causes a function call
#     console.log 'hi' is console.log('hi')
#   "#{value}" is just string interpolation
#     "The value is #{val}." is 'The value is' + val + '.'
#   And one bonus tip for the embedded JSX:
#     code is backticks (`) is just passed through unmodified
# And remember kids, CoffeeScript is just JavaScript!
# http://coffeescript.org/

Board = require './Board'
Piece = require './Piece'

nextTick = nextTick || (f) -> setTimeout(f, 0)

# @cjsx React.DOM

React = require 'react'

MainPage = React.createClass
  render: ->
    `<div className="MainPage">
      <h1>Hello, anonymous!</h1>
      <p><a href="/users/doe">Login</a></p>
    </div>`


UserPage = React.createClass

  statics:
    getUserInfo: (username, cb) ->
      superagent.get "http://localhost:3000/api/users/" + username, (err, res) ->
        cb err, (if res then res.body else null)

  render: ->
    otherUser = ( if @props.username is 'doe' then 'ivan' else 'doe' )
    `<div className="UserPage">
      <h1>Hello, {this.state.name}!</h1>
      <p>
        Go to <a href={"/users/" + otherUser}>/users/{otherUser}</a>
      </p>
      <p><a href="/">Logout</a></p>
    </div>`


BoardSurface = React.createClass
  render: ->
    rows = []
    cols = []
    [piece_row, piece_col] = @props.piece.currentPos()
    @props.board.visit (square, i, row, col) ->
      if col is 1
        rows.push `<tr key={rows.length+1}>{cols}</tr>` if cols?.length
        cols = []
      classNames = "go#{Board::toUDLR(square)}"
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

  mixIt: ->
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
        board: new Board( Math.pow(new_size, 2) ).randomize()

  moveNext: ->
    console.log 'moveNext'
    @state.piece.executeMove()
    @setState moves: @state.moves + 1


  render: ->
    `<div>
      <button onClick={this.mixIt}>mix it</button>
      <input type="number" className="size" min="1" max="99"
        onChange={this.changeIt} value={this.state.sizeInput}>
      </input>
      <button onClick={this.moveNext}>next</button>
      <BoardSurface board={this.state.board} piece={this.props.piece} />
    </div>`

    # <button onClick={this.reduceIt} disabled={this.state.size < 2}>-</button>


if window?
  window.onload = ->
    size = 8
    board = new Board( Math.pow(size, 2) ).randomize()
    piece = new Piece(board)
    piece.placeOnBoard(4, 4)
    React.render `<Game size={size} board={board} piece={piece}/>`, document.body
